define [
  "jquery"
  "underscore"
  "backbone"
  "models/Post"
  "models/Activity"
  "views/activity/Summary"
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/post/new"
  "templates/post/pending_photo"
  "templates/post/photo"
  'gmaps'
  'jquery.fileupload'
  'jquery.fileupload-fp'
  'jquery.fileupload-ui'
], ($, _, Parse, Post, Activity, ActivityView, i18nUser, i18nProperty, i18nCommon) ->

  class NewPostView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#new-post"

    events:
      "submit form"                     : "save"
      "focus #post-title"               : "showPostForm"
      # "change #show-body"               : "toggleBodyView"
      # "change #centered-on-property"    : "toggleCenterOnProperty"
      "click #building-post"            : "toggleBuildingPost"
      "click #post-type li input"       : "handlePostClick"
      "change #property-options select" : "setProperty"
      "click .photo-destroy"            : "unsetImage"
    
    initialize: (attrs) ->

      @model = new Post
      @view = attrs.view
      @listenTo Parse.Dispatcher, "user:logout", @clear

      @listenTo Parse.User.current(), "change:property change:network", @handlePossiblePropertyAdd
      if Parse.User.current().get("network")
        @listenTo Parse.User.current().get("network").properties, "add", @handlePropertyAdd

      @listenTo @model, "change:image", @renderImage

      @listenTo @model, "change:property", =>
        if @model.get "property"
          @marker.setVisible false
          @$('#property-options').removeClass 'hide'
          @pMarker = @model.get("property").marker
          @pMarker.setZIndex 100
          @view.map.setOptions
            draggable: false
            center: @model.get("property").GPoint()
            zoom: 14
        else
          @marker.setVisible true
          @pMarker.setZIndex 1
          @$('#property-options').addClass 'hide'
          @view.map.setOptions
            draggable: true

      @listenTo @view, "dragend", @updateCenter
      @updateCenter()

    renderImage: =>
      @$('#preview-post-photo').html if @model.get("image") then JST["src/js/templates/post/photo.jst"](image: @model.get("image"), i18nCommon: i18nCommon) else ""
      @trigger "view:resize"

    unsetImage: =>
      @model.unset("image")
      @trigger "view:resize"

    updateCenter : => center = @view.map.getCenter(); @model.set "center", new Parse.GeoPoint(center.lat(), center.lng())

    handlePostClick : =>
      index = @getTypeIndex()
      pos = @$("#post-input-caret").data "position"
      if index is pos 
        if @shown then @hidePostForm() else @showPostForm()
      else
        @changePostType()

    toggleBuildingPost: ->
      return if @empty
      @showPostForm()
      unless @model.get "property"
        @$('#building-post').addClass 'active'
        if Parse.User.current().get "network"
          @model.set "property", Parse.User.current().get("network").properties.models[0]
        else if Parse.User.current().get "property"
          @model.set "property", Parse.User.current().get("property")
      else
        @$('#building-post').removeClass 'active'
        @model.unset "property"

    setProperty : =>
      p = @$('#property-options select :selected').val()
      property = Parse.User.current().get("network").properties.get(p)
      unless property then property = Parse.User.current().get("property")
      @model.set "property", property

    changePostType : ->
      newPos = @getTypeIndex()
      pos = @$("#post-input-caret").data "position"
      rand = Math.floor Math.random() * i18nUser.form.share[0].length
      @$("#post-input-caret").addClass "phase-#{newPos}"
      @$("#post-input-caret").removeClass "phase-#{pos}"
      @$("#post-input-caret").data "position", newPos

      if @empty
        @$(".no-property").removeClass "hide"
      else
        @$(".no-property").addClass "hide"
        @$(".title-group").removeClass "hide"
        # @$("#post-title").removeProp 'disabled'
        # @$("#post-options").removeClass "hide"
        @$("#post-title").prop 'placeholder', i18nUser.form.share[newPos][rand]

    getTypeIndex: -> 
      index = @$("#post-type :checked").parent().index()
      return if index then index else 0

    render: =>

      @marker = new google.maps.Marker
        position:   @view.map.getCenter()
        map:        @view.map
        animation:  google.maps.Animation.DROP
        ZIndex:     101
        visible:    false
        title:      "Select where you want to place this post."

      @empty = false

      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty

      @$el.html JST["src/js/templates/post/new.jst"](vars)
      @$form = @$("> #post-form")

      @$('[rel=tooltip]').tooltip()

      if Parse.User.current().get("property")
        @$("#property-options").html "<strong>#{Parse.User.current().get("property").get("title")}</strong>"
        rand = Math.floor Math.random() * i18nUser.form.share.length
        @$("#post-type :nth-child(#{rand + 1}) input").prop('checked', true)
        @changePostType()

      else if Parse.User.current().get("network")

        # Render asynchronously, while we wait for the property
        # info to come in so we can determine our center & radius
        @$("#property-options").html "<select></select>"
        @listenTo Parse.User.current().get("network").properties, "add reset", @populatePropertySelectFromNetwork
        unless Parse.User.current().get("network").properties.length is 0
          @populatePropertySelectFromNetwork()
          rand = Math.floor Math.random() * i18nUser.form.share.length
          @$("#post-type :nth-child(#{rand + 1}) input").prop('checked', true)
          @changePostType()
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
        fileInput: '#attach-photo'
        # nameContainer:_this.$('#preview-post-photo-name')
        filesContainer: _this.$('#preview-post-photo')
        multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
        context: @$form[0]
        uploadTemplateId: "src/js/templates/post/pending_photo.jst"
        downloadTemplateId: "src/js/templates/post/photo.jst"
        add: (e, data) ->
          _this.showPostForm()

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
          # )
          .done ->
            $(this).find(".progress").attr("aria-valuenow", "0").find(".bar").css "width", "0%"
            $(this).find(".progress-extended").html "&nbsp;"
            deferred.resolve()
            $(this).find(".fileupload-progress")
          that._trigger "photo:remove", e

    populatePropertySelectFromNetwork : ->
      if Parse.User.current().get("network").properties.length > 0
        propertyOptions = ''
        Parse.User.current().get("network").properties.each (p) -> 
          propertyOptions += "<option value='#{p.id}'>#{p.get("title")}</option>"
        @$("#property-options > select").html propertyOptions
      else
        @handleNoProperty()

    handleNoProperty : ->
      @empty = true
      # Set to building-type, to show the user that they still need to join/add a property
      # @$("#post-type :nth-child(4) input").prop('checked', true)
      # @$("#post-input-caret").data "position", 3
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
      # @changePostType()

    handlePossiblePropertyAdd : =>
      if Parse.User.current().get("network")
        if Parse.User.current().get("network").properties.length > 0 then @handlePropertyAdd()
        else 
          @handleNoProperty()
          @listenTo Parse.User.current().get("network").properties, "add", @handlePropertyAdd
      else if Parse.User.current().get("property")
        @handlePropertyAdd()

    handlePropertyAdd : ->
      @empty = false
      @changePostType()
      # @$("#centered-on-property").parent().remove("p.empty")

    showPostForm : (e) => 
      newPos = @getTypeIndex()
      return if @shown # or newPos is 3 and @empty
      @shown = true
      @trigger "view:resize"
      @$('#post-options').removeClass 'hide'
      # if @empty then @$("#centered-on-property").prop("disabled", true)
      @marker.bindTo 'position', @view.map, 'center'
      @marker.setVisible true
      $("#redo-search").prop('checked', false).trigger("change") if $("#redo-search").is(":checked")

    hidePostForm : (e) => 
      return unless @shown
      @shown = false
      @trigger "view:resize"
      @$('#post-title').val('').blur()
      @$('#post-options').addClass 'hide'
      @marker.setVisible false

    # toggleBodyView : (e) =>
    #   if e.currentTarget.checked then @$('.body-group').removeClass 'hide'
    #   else @$('.body-group').addClass 'hide'

    save : (e) ->
      e.preventDefault() if e

      @$('button.save').prop "disabled", true
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')

      @model.save data.post,
        success: (model) => 
          model.set 
            activity_type: "new_post"
            profile: Parse.User.current().get("profile")
          # Add to appropriate collection
          if model.get("property")
            Parse.User.current().activity.add new Activity(model.attributes)
          else Parse.App.activity.add new Activity(model.attributes)

          @view.refreshDisplay()

          # Reset
          @model = new Post
          @marker.setMap null
          @shown = false
          @render()
        error: (model, error) => console.log error

    # attachPhoto: ->


    clear: (e) =>
      @$el.html ""
      @stopListening()
      @undelegateEvents()
      delete this