define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "views/helper/Alert"
  "views/property/new/Map"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/new/map"
  "templates/property/new/wizard"
], ($, _, Parse, Property, Unit, Lease, Alert, GMapView, i18nProperty, i18nCommon) ->

  class PropertyWizardView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    
    className: 'wizard'
    
    state: 'address'
    
    events:
      'click .back'         : 'back'
      'click .next'         : 'next'
      # 'click .cancel'       : 'cancel'
    
    initialize : (attrs) ->

      @forNetwork = if attrs and attrs.forNetwork then true else false

      @model = new Property
      @model.set "network", Parse.User.current().get("network") if @forNetwork 

      @map = new GMapView(wizard: @, model: @model, forNetwork: @forNetwork)
      @listenTo @map, "property:join", @join
      @listenTo @map, "property:manage", @manage

      @listenTo @model, "invalid", (error) =>
        @$('button.next').removeProp "disabled"

        msg = if error.message.indexOf(":") > 0  
          args = error.message.split ":"
          fn = args.pop()
          i18nProperty.errors[fn](args[0])
        else
          i18nProperty.errors[error.message]

        switch error.message
          when 'title_missing' then @$('#property-title-group').addClass('error')
          else @$('#address-search-group').addClass('error')
        
        new Alert event: 'model-save', fade: false, message: msg, type: 'error'

      @on "property:save", (property) =>
        # Add new property to collection
        Parse.User.current().get("network").properties.add property
        Parse.history.navigate "/", trigger: true
        # @clear()

      @on "lease:save", (lease, isNew) =>
        vars = 
          lease: lease
          unit: lease.get "unit"
          property: lease.get "property"
          mgrOfProp: isNew
        Parse.User.current().save(vars).then ->
          Parse.history.navigate "/account/building", true
          @clear()
        , (error) -> console.log error


    render : ->
      vars = 
        i18nCommon: i18nCommon
        setup: !Parse.User.current() or (!Parse.User.current().get("property") and !Parse.User.current().get("network"))
      @$el.html JST['src/js/templates/property/new/wizard.jst'](vars)
      @$el.find(".wizard-forms").append @map.render().el
      @map.renderMap()
      @

    join : (existingProperty) =>
      return if @state is 'join'
      @$('.error').removeClass('error')
      @$('button.next').prop "disabled", "disabled"
      @$('button.join').prop "disabled", "disabled"
      @state = 'join'
      @existingProperty = existingProperty

      require ["views/property/new/Join"], (JoinPropertyView) =>
        @form = new JoinPropertyView wizard: @, property: @existingProperty
        @map.$el.after @form.render().el
        @animate 'forward'

    manage : (existingProperty) =>
      @$('.error').removeClass('error')
      @$('button.next').prop "disabled", "disabled"
      @$('button.join').prop "disabled", "disabled"

      require ["models/Concierge"], (Concierge) =>
        concierge = new Concierge
          property: existingProperty
          profile: Parse.User.current().get("profile")
          state: 'pending'

        alert = new Alert event: 'model-save', fade: false, message: i18nCommon.actions.request_sent, type: 'error'
        concierge.save().then @clear , 
          (error) -> alert.setError i18nCommon.errors.unknown_error


    next : (e) =>
      @$('.error').removeClass('error')
      @$('button.next').prop "disabled", "disabled"
      @$('button.join').prop "disabled", "disabled"
      switch @state
        when 'address'
          center = @model.get "center"
          return @model.trigger "invalid", {message: 'invalid_address'} if center._latitude is 0 and center._longitude is 0
          if @model.get("thoroughfare"                ) is '' or 
             @model.get("locality"                    ) is '' or
             @model.get("administrative_area_level_1" ) is '' or
             @model.get("country"                     ) is '' or
             @model.get("postal_code"                 ) is ''
            return @model.trigger "invalid", {message: 'insufficient_data'}

          @state = 'property'
          @model.set 'title', @model.get('thoroughfare')

          if @forNetwork
            require ["views/property/new/New"], (NewPropertyView) =>
              @form = new NewPropertyView wizard: @, model: @model
              @map.$el.after @form.render().el
              @animate 'forward'
          else        
            require ["views/property/new/Join"], (JoinPropertyView) =>
              @form = new JoinPropertyView wizard: @, property: @model
              @map.$el.after @form.render().el
              @animate 'forward'
              
        when 'property'
          data = @form.$el.serializeObject()
          if data.lease
            attrs = @form.model.scrub data.lease
            attrs = @assignAdditionalToLease data, attrs
            @form.model.save attrs,
              success: (lease) =>        @trigger "lease:save", @form.model, false
              error: (lease, error) =>   @form.model.trigger "invalid", error; console.log error

          else 
            attrs = @model.scrub data.property
            @model.save attrs,
              success: (property) =>        @trigger "property:save", @model
              error: (property, error) =>   @model.trigger "invalid", error; console.log error

        when 'join'
          data = @form.$el.serializeObject()
          attrs = @form.model.scrub data.lease
          attrs = @assignAdditionalToLease data, attrs
          
          @form.model.save attrs,
              success: (lease) =>        @trigger "lease:save", @form.model, true
              error: (lease, error) => @form.model.trigger "invalid", error; console.log error

    back : (e) =>
      return if @state is 'address'
      delete @existingProperty
      @$('button.join').removeProp "disabled"
      @state = 'address'
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
        @$('.emails-group').addClass('error')
        @model.trigger "invalid", {message: 'tenants_incorrect'}
        false
      else
        attrs

    animate : (dir) ->
      switch dir
        when 'forward'
          @map.$el.animate left: "-150%", 500
          @form.$el.animate left: "0", 500, 'swing', =>
            @$('.next').removeProp "disabled"
            @$('.next').html(i18nCommon.actions.save)
            @$('.back').prop disabled: false
        when 'backward'
          @map.$el.animate left: "0%", 500
          @form.$el.animate left: "150%", 500, 'swing', =>
            @form.remove()
            @form.undelegateEvents()
            delete @form
          @$('.back').prop disabled: 'disabled'
          @$('.next').html(i18nCommon.actions.create)

    clear : ->
      @stopListening()
      @undelegateEvents()
      delete this