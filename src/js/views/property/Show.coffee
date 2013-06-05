define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  'models/Unit'
  'models/Lease'
  'models/Inquiry'
  "i18n!nls/property"
  "i18n!nls/common"
  "underscore.inflection"
  'templates/property/show'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, Property, Unit, Lease, Inquiry, i18nProperty, i18nCommon, inflection) ->

  class ShowPropertyView extends Parse.View

    el: '#main'
    
    events:
      'click .edit-profile-picture': 'editProfilePicture'

    initialize: (attrs) ->
            
      @$form = $("#profile-picture-upload")
      
      @model.prep('units')
      @model.prep('leases')
      @model.prep('listings')
      @model.prep('inquiries')
      
      @model.on 'change:image_profile', (model, name) => @refresh
      @model.on 'destroy',  @clear
      
      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        publicUrl: @model.publicUrl()
        cover: @model.cover 'profile'
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      )
      
      @$el.html JST["src/js/templates/property/show.jst"](vars)
      @

    changeSubView: (path, params) =>
      
      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")
      
      action = if path then path.split("/") else Array('units')
      
      if action.length is 1 or action[0] is "add"
        name = "views/property/sub/#{action.join("/")}"
        @renderSubView name, model: @model, params: params 
        
      else

        # Subnode view
        propertyCentric = false
        node = action[0][0].toUpperCase() + inflection.singularize[action[0]].substring(1) # units => Unit
        subid = action[1]
        subaction = if action[2] then action[2] else "show"
        name = "views/#{node}/#{subaction}"

        # Load the model if it exists.
        submodel = if @model[action[0]] then @model[action[0]].get(subid) else false

        if submodel
          @renderSubView name, property: @model, model: submodel
        # Else get it from the server.
        else
          nodeType = switch action[0]
            when "inquiries" then Inquiry
            when "leases" then Lease
            when "units" then Unit
          (new Parse.Query(nodeType)).get subid, success: (submodel) =>
            @renderSubView name, property: @model, model: submodel


    renderSubView: (name, vars) =>
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass 'in'
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars).render()
        @$('.content').addClass 'in'
  
    # Re-render the contents of the property item.
    refresh: ->
      $('#preview-profile-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      Parse.User.current().get("network").properties.trigger "close"
      @undelegateEvents()
      @remove()
      delete this
    
    editProfilePicture: ->
      
      _this = @ # Keep for below
      
      require ['jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-pr'],  =>
        
        # Initiate the file upload.
        @$form.fileupload
          autoUpload: false
          type: "POST"
          dataType: "json"
          # fileInput: '#file-input'
          nameContainer: $('#preview-profile-picture-name')
          filesContainer: $('#preview-profile-picture')
          multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
          context: @$form[0]
          submit: (e, data) ->
            data.url = "https://api.parse.com/1/files/" + data.files[0].name
          send: (e, data) ->
            delete data.headers['Content-Disposition']; # Parse does not accept this header.
          done: (e, data) ->
            file = data.result
            _this.model.save image_thumb: file.url, image_profile: file.url, image_full: file.url
            $('#edit-profile-picture-modal').modal('hide')
                
        $('#edit-profile-picture-modal').modal()
        