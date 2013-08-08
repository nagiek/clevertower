define [
  "jquery"
  "underscore"
  "backbone"
  "models/Activity"
  "views/helper/Alert"
  "views/activity/BaseNew"
  "views/activity/Summary"
  'views/user/AppsModal'
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "plugins/toggler"
  "templates/activity/new"
  "templates/activity/pending_photo"
  "templates/activity/photo"
  'gmaps'
  "datepicker"
  'jquery.fileupload'
  'jquery.fileupload-fp'
  'jquery.fileupload-ui'
], ($, _, Parse, Activity, Alert, BaseNewActivityView, ActivityView, AppsModalView, i18nUser, i18nProperty, i18nCommon) ->

  class NewActivityView extends BaseNewActivityView
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#new-activity"

    events:
      "submit form"                     : "save"
      "focus #activity-title"           : "showActivityForm"
      # "change #show-body"               : "toggleBodyView"
      # "change #centered-on-property"    : "toggleCenterOnProperty"
      "change #toggle-end-date"         : "toggleEndDate"
      "click #add-property"             : "toggleBuildingActivity"
      "click #add-time"                 : "toggleTime"
      # "click #activity-type li input"   : "handleActivityClick"
      "change #property-options select" : "setProperty"
      "click .photo-destroy"            : "unsetImage"
      # Share options
      "change #post-as-property"        : "togglePostAsProperty"
      "change #post-private"            : "togglePostPrivate"
      # Original from BaseNewActivityView.
      "toggle:on .facebook-group .toggle": "checkShareOnFacebook"
    
    initialize: (attrs) ->

      @view = attrs.view

      @listenTo Parse.Dispatcher, "user:logout", @clear

      @model = new Activity
        activity_type: "new_post"
        profile: Parse.User.current().get("profile")
        public: true
        isEvent: false

      @dragListener = google.maps.event.addListener @view.map, 'dragend', @updateCenter


    # Mid level functions
    # -------------------

    unsetImage: =>
      @model.unset("image")
      @trigger "view:resize"

    togglePostAsProperty: ->
      if @model.get "profile" then @model.unset "profile"
      else @model.set "profile", Parse.User.current().get("profile")

    togglePostPrivate: ->
      if @$("#post-private").is(":checked") then @model.set("public", false) else @model.set("public", true)

    toggleTime: ->
      unless @model.get "isEvent"
        @$("#event-options").removeClass "hide"
        @model.set "start_date", @$(".start-date").val()
        @model.set "end_date", @$(".end-date").val()
        @$('#add-time').addClass 'active'
        @model.set "isEvent", true
        @showActivityForm()
      else 
        @$("#event-options").addClass "hide"
        @model.unset "start_date"
        @model.unset "end_date"
        @$('#add-time').removeClass 'active'
        @model.set "isEvent", false
        @trigger "view:resize"

    toggleEndDate: ->
      if @$('#toggle-end-date').is ":checked"
        @$('#end-date').removeClass "hide"
      else
        @$('#end-date').addClass "hide"


    # Misc functions
    # --------------------

    renderImage: =>
      @$('#preview-activity-photo').html if @model.get("image") then JST["src/js/templates/activity/photo.jst"](image: @model.get("image"), i18nCommon: i18nCommon) else ""
      @trigger "view:resize"

    updateCenter : =>
      center = @view.map.getCenter()
      @model.set "center", new Parse.GeoPoint(center.lat(), center.lng())

    toggleBuildingActivity: ->
      return unless @hasProperty
      unless @model.get "property"
        @showActivityForm()
        @$('#add-property').addClass 'active'
        if Parse.User.current().get "network"
          @model.set "property", Parse.User.current().get("network").properties.models[0]
        else if Parse.User.current().get "property"
          @model.set "property", Parse.User.current().get("property")
      else
        @$('#add-property').removeClass 'active'
        @model.unset "property"
        # Don't post as property.
        @$("#post-as-property").prop "checked", false 
        @model.set "profile", Parse.User.current().get("profile")
        # Post publicly
        @$("#post-private").prop "checked", true
        @model.set "public", true
      @trigger "view:resize"


    # Prop select functions
    # ---------------------

    setProperty : =>
      p = @$('#property-options select :selected').val()
      property = Parse.User.current().get("network").properties.get(p)
      unless property then property = Parse.User.current().get("property")
      @model.set "property", property


    populatePropertySelectFromNetwork : ->
      if Parse.User.current().get("network").properties.length > 0
        propertyOptions = ''
        Parse.User.current().get("network").properties.each (p) -> 
          propertyOptions += "<option value='#{p.id}'>#{p.get("title")}</option>"
        @$("#property-options select").html propertyOptions
      else
        @handleNoProperty()

    handleNoProperty : ->
      @hasProperty = false
      # Set to building-type, to show the user that they still need to join/add a property
      # @$("#activity-type :nth-child(4) input").prop('checked', true)
      # @$("#activity-input-caret").data "position", 3
      # @$("#centered-on-property").parent().append("<p class='empty'><small>(#{i18nProperty.empty.properties})</small></p>")
      if Parse.User.current().get("network")
        @$('.no-property').html """
                          <p>CleverTower is more fun when you're connected, but you haven't added any property yet.</p>
                          <a class="btn btn-primary btn-block" href='#{Parse.User.current().get("network").privateUrl()}'>
                            #{i18nProperty.actions.add_a_property}
                          </a>
                          """
      else 
        @$('.no-property').html """
                    <p>CleverTower is more fun when you're connected, but you haven't joined a property yet.</p>
                    <a class="btn btn-primary btn-block" href='/account/setup'>
                      #{i18nCommon.expressions.get_started}
                    </a>
                    """
      # @changeActivityType()

    handlePossiblePropertyAdd : =>
      if Parse.User.current().get("network")
        if Parse.User.current().get("network").properties.length > 0 then @handlePropertyAdd()
        else 
          @handleNoProperty()
          # We have just created a network, therefore add the listeners.
          @listenTo Parse.User.current().get("network").properties, "add", @handlePropertyAdd
      else if Parse.User.current().get("property")
        @handlePropertyAdd()

    handlePropertyAdd : ->
      @hasProperty = true
      # @changeActivityType()
      # @$("#centered-on-property").parent().remove("p.empty")

    # View functions
    # --------------

    undelegateEvents: ->
      google.maps.event.removeListener @dragListener
      super

    render: =>

      # Model may change, so have to re-establish listeners on render.
      @listenTo @model, 'invalid', @handleError

      @listenTo Parse.User.current(), "change:property change:network", @handlePossiblePropertyAdd
      if Parse.User.current().get("network")
        @listenTo Parse.User.current().get("network").properties, "add", @handlePropertyAdd

      @listenTo @model, "change:image", @renderImage

      @listenTo @model, "change:property", =>

        if @model.get "property"

          # We are private by default when posting to the property. Adjust model accordingly.
          @togglePostPrivate()
          @$("#activity-profile-pic").prop "src", @model.get("property").cover("tiny") unless @model.get "profile"
          @marker.setVisible false
          @$('#property-options').removeClass 'hide'
          # @model.get("property").marker.setZIndex 100
          @view.map.setOptions
            draggable: false
            center: @model.get("property").GPoint()
            zoom: 14
        else
          @model.set "public", true
          @marker.setVisible true
          @$('#property-options').addClass 'hide'
          @view.map.setOptions
            draggable: true

      @listenTo @model, "change:profile", =>
        if @model.get("property") and not @model.get("profile")
          # Property profile pic
          @$("#activity-profile-pic").prop "src", @model.get("property").cover("tiny")
        else
          # User profile pic
          @$("#activity-profile-pic").prop "src", Parse.User.current().get("profile").cover("tiny")

      @updateCenter()

      @marker = new google.maps.Marker
        position:   @view.map.getCenter()
        map:        @view.map
        animation:  google.maps.Animation.DROP
        ZIndex:     101
        visible:    false
        title:      "Select where you want to place this activity."

      @hasProperty = true

      vars = 
        profilePic: Parse.User.current().get("profile").cover("tiny")
        fbLinked: Parse.User.current()._isLinked("facebook")
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty

      @$el.html JST["src/js/templates/activity/new.jst"](vars)

      @$(".toggle").toggler()

      @$form = @$("> #activity-form")

      # Set a placeholder
      rand = Math.floor Math.random() * i18nUser.form.share.length
      @$("#activity-title").prop 'placeholder', i18nUser.form.share[0][rand]

      # Only allow posting as property if we are a manager.
      if (Parse.User.current().get("property") and Parse.User.current().get("property").get("mgrRole")) or
      # Or if this is our network.
      (Parse.User.current().get("network") and Parse.User.current().get("network").get("role"))
        @$("#post-as-property").parent().removeClass "hide"

      @$('[rel=tooltip]').tooltip
      @$('.datepicker').datepicker()

      if Parse.User.current().get("property")
        @$("#property-options .controls").html "<strong>#{Parse.User.current().get("property").get("title")}</strong>"
        # rand = Math.floor Math.random() * i18nUser.form.share.length
        # @$("#activity-type :nth-child(#{rand + 1}) input").prop('checked', true)
        # @changeActivityType()

      else if Parse.User.current().get("network")

        # Render asynchronously, while we wait for the property
        # info to come in so we can determine our center & radius
        @$("#property-options .controls").html "<select></select>"
        @listenTo Parse.User.current().get("network").properties, "add reset", @populatePropertySelectFromNetwork
        unless Parse.User.current().get("network").properties.length is 0
          @populatePropertySelectFromNetwork()
          # rand = Math.floor Math.random() * i18nUser.form.share.length
          # @$("#activity-type :nth-child(#{rand + 1}) input").prop('checked', true)
          # @changeActivityType()
        else
          @handleNoProperty()
      else
        @handleNoProperty()

      # Init the form upload.
      _this = @ # Keep for below
        
      # Initiate the file upload.
      @$form.fileupload
        autoUpload: true
        type: "POST"
        dataType: "json"
        fileInput: '#add-photo'
        # nameContainer:_this.$('#preview-activity-photo-name')
        filesContainer: _this.$('#preview-activity-photo')
        multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
        context: @$form[0]
        uploadTemplateId: "src/js/templates/activity/pending_photo.jst"
        downloadTemplateId: "src/js/templates/activity/photo.jst"
        add: (e, data) ->
          _this.showActivityForm()

          # Copy/Paste from jquery.fileupload-ui
          that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
          that._trigger "photo:add", e, data
          options = that.options
          files = data.files
          $(this).fileupload("process", data).done ->
            that._adjustMaxNumberOfFiles -files.length
            data.maxNumberOfFilesAdjusted = true
            data.files.valid = data.isValidated = that._validate(files)
            data.context = that._renderUpload(files).data("data", data)
            # replace existing picture.
            options.filesContainer.html data.context
            that._renderPreviews data
            that._forceReflow data.context
            that._transition(data.context).done ->
              _this.trigger "view:resize"
              data.submit()  if (that._trigger("added", e, data) isnt false) and (options.autoUpload or data.autoUpload) and data.autoUpload isnt false and data.isValidated
        submit: (e, data) ->
          data.url = "https://api.parse.com/1/files/" + data.files[0].name
        send: (e, data) ->
          delete data.headers['Content-Disposition']; # Parse does not accept this header.
        done: (e, data) ->
          file = data.result

          _this.model.set image: file.url

        stop: (e) ->
          that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
          deferred = that._addFinishedDeferreds()
          $.when.apply($, that._getFinishedDeferreds()).done ->
            that._trigger "stopped", e

          # that._transition(
          $(this).find(".fileupload-progress").addClass('hide')
          # ).done ->
          $(this).find(".progress").attr("aria-valuenow", "0").find(".bar").css "width", "0%"
          $(this).find(".progress-extended").html "&nbsp;"
          deferred.resolve()
          $(this).find(".fileupload-progress")
          that._trigger "photo:remove", e
      @



    showActivityForm : (e) => 
      return if @shown
      @shown = true
      @$('#activity-options').removeClass 'hide'
      # if @hasProperty then @$("#centered-on-property").prop("disabled", true)
      @marker.bindTo 'position', @view.map, 'center'
      @marker.setVisible true
      $("#redo-search").prop('checked', false).trigger("change") if $("#redo-search").is(":checked")
      @trigger "view:resize"

      if @hasProperty
        @$(".no-property").addClass "hide"
        @$(".title-group").removeClass "hide"
        # @$("#activity-title").removeProp 'disabled'
        # @$("#activity-options").removeClass "hide"
      else
        @$(".no-property").removeClass "hide"

    hideActivityForm : (e) => 
      return unless @shown
      @shown = false
      @$('#activity-title').val('').blur()
      @$('#activity-options').addClass 'hide'
      @marker.setVisible false
      @trigger "view:resize"

    save : (e) ->
      e.preventDefault() if e

      @$('button.save').prop "disabled", true
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')

      return @model.trigger "invalid", error: message: i18nCommon.errors.no_data unless data.activity.title or @model.get("image")

      attrs = 
        title: data.activity.title

      if @model.get("isEvent")
        
        return @model.trigger "invalid", error: message: i18nCommon.errors.no_start_date unless data.activity.start_date
        attrs.startDate = new Date("#{data.activity.start_date} #{data.activity.start_time}")
        if @$('#toggle-end-date').is ":checked"
          return @model.trigger "invalid", error: message: i18nCommon.errors.no_end_date unless data.activity.end_date
          attrs.endDate = new Date("#{data.activity.end_date} #{data.activity.end_time}") if data.activity.end_date

      @model.save(attrs).then (model) => 
        # Add to appropriate collection
        if @model.get("property")
          Parse.User.current().activity.add @model, silent: true
        else Parse.App.activity.add @model, silent: true

        @trigger "model:save", @model

        # Share on FB?
        if data.share.fb is "on" or data.share.fb is "1"
          vars =
            object: window.location.origin + @model.publicUrl()
            message: @model.get("title")
            place: @model.GPoint()

          # Optional Event params.
          vars.start_time = attrs.startDate if attrs.startDate
          vars.end_time = attrs.endDate if attrs.endDate

          # Add city if we have set one up.
          city = @model.city()
          if _.contains _.keys(Parse.App.cities), city
            vars.city = window.location.origin + city

          window.FB.api 'me/og:posts',
            'post', vars,
            (response) -> # handle the response

        # Reset
        @model = new Activity
          activity_type: "new_post"
          profile: Parse.User.current().get("profile")
          public: true
          isEvent: false

        @listenTo @model, 'invalid', @handleError
        @marker.setMap null
        @view.map.setOptions draggable: true
        @shown = false
        @render()
      , (error) => console.log error

    # attachPhoto: ->
    handleError: (error) =>
      @$('.error').removeClass('error')
      @$('button.save').removeProp "disabled"

      console.log error

      msg = i18nCommon.errors[error]

      new Alert event: 'model-save', fade: false, message: msg, type: 'error'
      switch error.message
        when 'unit_missing'
          @$('.unit-group').addClass('error')
        when 'dates_missing' or 'dates_incorrect'
          @$('.date-group').addClass('error')

    clear: (e) =>
      @$el.html ""
      @stopListening()
      @undelegateEvents()
      delete this