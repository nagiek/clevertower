define [
  "jquery"
  "underscore"
  "backbone"
  "collections/ActivityList"
  "models/Activity"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "models/Concierge"
  "views/helper/Alert"
  "views/property/new/Map"
  "views/property/new/New"
  "views/property/new/Join"
  "views/property/new/Picture"
  "views/property/new/Share"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/new/map"
  "templates/property/new/wizard"
], ($, _, Parse, ActivityList, Activity, Property, Unit, Lease, Concierge, Alert, GMapView, NewPropertyView, JoinPropertyView, PicturePropertyView, SharePropertyView, i18nProperty, i18nCommon) ->

  class PropertyWizardView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    
    className: 'wizard'

    # Displayed form.
    state: 'address'

    # Finish path for when we're done.
    path: "/"
    
    events:
      'click .back'         : 'back'
      'click .next'         : 'next'
      # 'click .cancel'       : 'cancel'
    
    initialize : (attrs) ->

      @forNetwork = if attrs and attrs.forNetwork then true else false

      @model = new Property
      @model.set "network", Parse.User.current().get("network") if @forNetwork 

      @listenTo Parse.Dispatcher, 'user:logout', -> Parse.history.navigate "", true

      @listenTo @model, "invalid", (error) =>
        @buttonsForward()

        console.log error

        msg = if error.message.indexOf(":") > 0  
          args = error.message.split ":"
          fn = args.pop()
          i18nProperty.errors[fn](args[0])
        else
          i18nProperty.errors[error.message]

        switch error.message
          when 'title_missing' then @$('#property-title-group').addClass('has-error')
          else @$('#address-search-group').addClass('has-error')
        
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'

      @on "property:save", (property) =>
        # Add new property to collection
        Parse.User.current().get("network").properties.add property

      @on "lease:save", (lease) =>
        vars = 
          lease: lease
          unit: lease.get "unit"
          property: lease.get "property"
        Parse.User.current().set(vars)
        @path = "/account/building"

      @on "wizard:finish", => Parse.history.navigate @path, true


    render : ->
      vars = 
        i18nCommon: i18nCommon
        setup: !Parse.User.current() or (!Parse.User.current().get("property") and !Parse.User.current().get("network"))
      @$el.html JST['src/js/templates/property/new/wizard.jst'](vars)

      @map = new GMapView(wizard: @, model: @model, forNetwork: @forNetwork)
      @listenTo @map, "property:join", @join
      @listenTo @map, "property:manage", @manage
      @$(".wizard-forms").append @map.render().el
      @map.renderMap()

      @

    join : (existingProperty) =>
      return if @state is 'join'
      @$('.has-error').removeClass('has-error')
      @$('button.next').button('loading') # prop "disabled", true
      @$('button.join').button('loading') # prop "disabled", true
      @state = 'join'
      @existingProperty = existingProperty
      
      @form = new JoinPropertyView wizard: @, property: @existingProperty
      @map.$el.after @form.render().el
      @animate 'forward'

    manage : (existingProperty) =>
      @$('.has-error').removeClass('has-error')
      @$('button.next').button('loading') # prop "disabled", true
      @$('button.join').button('loading') # prop "disabled", true

      concierge = new Concierge
        property: existingProperty
        profile: Parse.User.current().get("profile")
        state: 'pending'

      alert = new Alert event: 'model-save', fade: false, message: i18nCommon.actions.request_sent
      concierge.save().then -> @trigger "wizard:finish", 
        (error) -> alert.setError i18nCommon.errors.unknown_error


    next : (e) =>
      @$('.has-error').removeClass('has-error')
      @$('button.next').button('loading') # prop "disabled", true
      @$('button.join').button('loading') # prop "disabled", true
      switch @state
        when 'address'
          center = @model.get "center"
          if center.latitude is 0 and center.longitude is 0
            @model.trigger "invalid", {message: 'invalid_address'}
          else unless @model.get("thoroughfare"            ) and # is '' or 
                       @model.get("locality"                    ) and # is '' or
                         ( @model.get("administrative_area_level_1" ) or
                           @model.get("administrative_area_level_2" ) ) and # is '' or
                       @model.get("country"                     ) and # is '' or
                       @model.get("postal_code"                 )     # is ''
            @model.trigger "invalid", {message: 'insufficient_data'}
          else
            @state = 'property'
            @model.set 'title', @model.get('thoroughfare')

            if @forNetwork  
              @form = new NewPropertyView wizard: @, model: @model
              @map.$el.after @form.render().el
              @animate 'forward'
            else
              @form = new JoinPropertyView wizard: @, property: @model
              @map.$el.after @form.render().el
              @animate 'forward'
              

        # New property steps
        # ------------------

        when 'property'
          data = @form.$el.serializeObject()
          if data.lease
            attrs = @form.model.scrub data.lease
            attrs = @assignAdditionalToLease data, attrs
            @form.model.save(attrs).then (lease) =>
              # Might be necessary?
              # @model = @form.model.get("property")
              @trigger "lease:save", @form.model
              @state = 'picture'
              @picture = new PicturePropertyView wizard: @, model: @model
              @form.$el.after @picture.render().el
              @animate 'forward'
            , (error) => @form.model.trigger "invalid", error

          else 
            attrs = @model.scrub data.property
            @model.save(attrs).then (property) =>
              @trigger "property:save", @model  
              @state = 'picture'
              @picture = new PicturePropertyView wizard: @, model: @model
              @form.$el.after @picture.render().el
              @animate 'forward'
            , (error) => @model.trigger "invalid", error

        when 'picture'
          @model.save().then (property) => 
            @state = 'share'
            @share = new SharePropertyView wizard: @, model: @model
            @picture.$el.after @share.render().el
            @animate 'forward'
          , (error) => @model.trigger "invalid", error

        when 'share'
          data = @share.$el.serializeObject()
          attrs = @model.scrub data.property

          @model.save(attrs).then (property) =>                      
            # Share on CT?
            if data.share.ct is "on" or data.share.ct is "1"
              activity = new Activity
              activityACL = new Parse.ACL
              activityACL.setPublicReadAccess true
              activity.save
                activity_type: "new_property"
                public: true
                center: @model.get "center"
                property: @model
                network: Parse.User.current().get("network")
                title: data.activity.title
                profile: Parse.User.current().get("profile")
                ACL: activityACL
              .then ->
                Parse.User.current().activity = Parse.User.current().activity || new ActivityList [], {}
                Parse.User.current().activity.add activity

              # Share on FB?
              if data.share.fb is "on" or data.share.fb is "1"
                if @forNetwork
                  window.FB.api 'me/clevertower:become_a_landlord_in',
                    'post',
                    {
                      city: window.location.origin + @model.city()
                    },
                    (response) -> console.log response
                else
                  window.FB.api 'me/clevertower:move_into',
                  'post',
                  {
                    city: window.location.origin + @model.city()
                  },
                  (response) -> console.log response

            @trigger "wizard:finish"
          , (error) => @model.trigger "invalid", error


        # Join steps
        # ----------

        when 'join'
          data = @form.$el.serializeObject()
          attrs = @form.model.scrub data.lease
          attrs = @assignAdditionalToLease data, attrs

          # new Lease(forNetwork: @forNetwork, property: @existingProperty).save().then (lease) =>           
          @form.model.save(attrs).then (lease) => 
            @trigger "lease:save", @form.model
            @trigger "wizard:finish"
          , (error) => 
            @buttonsForward()
            @form.model.trigger "invalid", error

    back : (e) =>
      return if @state is 'address'
      @animate 'backward'

    # cancel : (e) =>
    #   @trigger "wizard:cancel", this
    #   @clear()

    assignAdditionalToLease : (data, attrs) -> 

      # Assign the lease to the property.
      # 
      # If the property is new and we are creating a lease, we cannot assign it
      # to both the unit AND the property. Therefore we will assign it to the
      # lease and come back for it later, if we ever do a mass transfer or somthing.

      if @existingProperty

        # Set pointers to the property, as we will not have write access if we are joining.
        unit = new Unit data.unit.attributes
        unit.set "property", @existingProperty
        attrs.unit = unit
        attrs.property = @existingProperty
      else 
        # We are creating a new property.
        property = @model
        property.set @model.scrub(data.property)

        unit = new Unit data.unit.attributes
        unit.set "property", property
        attrs.unit = unit
        attrs.property = property
      
      # Validate tenants (assignment done in Cloud)
      userValid = true
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        attrs.emails = []
        # _.each data.emails.split(","), (email) =>
        for email in data.emails.split(",")
          email = _.str.trim email
          # validate is a backwards function.
          userValid = unless Parse.User::validate(email: email) then true else false
          break unless userValid
          attrs.emails.push email
      
      unless userValid
        @$('.emails-group').addClass('has-error')
        @model.trigger "invalid", {message: 'tenants_incorrect'}
        false
      else
        attrs

    animate : (dir) ->
      switch dir
        when 'forward'
          switch @state
            when "property", "join"
              @trigger "view:advance"
              @$('.back').removeProp "disabled"
              @map.$el.transition left: "-150%"
              @form.$el.transition left: "0", @buttonsForward
              # @form.$el.animate left: "0", 500, 'swing', @buttonsForward
            when "picture"
              # @form.$el.animate left: "-150%", 500
              @form.$el.transition left: "-150%"
              @picture.$el.transition left: "0", @buttonsForward
              # @picture.$el.animate left: "0", 500, 'swing', @buttonsForward
            when "share"
              @$('.next').html i18nCommon.actions.finish
              # @picture.$el.animate left: "-150%", 500
              @picture.$el.transition left: "-150%"
              @share.$el.transition left: "0", @buttonsForward
              # @share.$el.animate left: "0", 500, 'swing', @buttonsForward
        when 'backward'
          switch @state
            when "property", "join"
              @trigger "view:retreat"
              # @map.$el.animate left: "0%", 500
              @map.$el.transition left: "0"
              @form.$el.transition left: "150%", => @form.clear();  @$('.back').prop "disabled", true
              # @form.$el.animate left: "150%", 500, 'swing', => @form.clear();  @$('.back').prop "disabled", true
              delete @existingProperty
              @state = 'address'
              @$('.back').prop "disabled", true
            when "picture"
              # @form.$el.animate left: "0%", 500
              @form.$el.transition left: "0"
              @picture.$el.transition left: "150%", @picture.clear
              # @picture.$el.animate left: "150%", 500, 'swing', @picture.clear
              @state = 'property'
            when "share"
              # @$('.next').html i18nCommon.actions.next
              # @picture.$el.animate left: "0%", 500
              @picture.$el.transition left: "0"
              @share.$el.transition left: "150%", @share.clear
              # @share.$el.animate left: "150%", 500, 'swing', @share.clear
              @state = 'picture'

    buttonsForward: =>
      @$('.next').button('reset') # .removeProp "disabled"
      @$('.join').button('reset') # .removeProp "disabled"
      switch @state
        when "share"
          @$('.next').html i18nCommon.actions.finish
          @$('.join').html i18nCommon.actions.join
        else
          @$('.next').html i18nCommon.actions.next
          @$('.join').html i18nCommon.actions.join

    clear : =>
      @stopListening()
      @undelegateEvents()
      delete this