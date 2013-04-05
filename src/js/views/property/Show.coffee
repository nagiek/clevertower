define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  "underscore.inflection"
  'templates/property/show'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, Property, i18nProperty, i18nCommon, inflection) ->

  class PropertyView extends Parse.View

    el: '#property'
    # tagName: "div"
    # id: "property"
    
    events:
      'click .edit-profile-picture': 'editProfilePicture'

    initialize: (attrs) ->
      
      # Bind this outside of events, as it is not with $el
      $('.home').on 'click', @clear
            
      @$form = $("#profile-picture-upload")
      
      @model.on 'change:image_profile', (model, name) => @refresh
      @model.on 'destroy',  @clear
      
      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        cover: @model.cover 'profile'
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      )
      
      @$el.html JST["src/js/templates/property/show.jst"](vars)
      @

    changeSubView: (path, params) =>
      
      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")
      
      console.log path
      action = if path then path.split("/") else Array('units')
      
      if action.length is 1 or action[0] is "add"
        # vars = model: @model, params: params
        # 
        # # Get the query string, if it exists.
        # querystring = e.currentTarget.search
        # if querystring.length > 0
        #   # Remove the leading "?" and split into components
        #   queryComponents = querystring.substring(1).split('&')
        #   vars.params = {}
        #   d = decodeURIComponent
        #   # march and parse
        #   for combo in queryComponents
        #     pair = combo.split('=')
        #     vars.params[d(pair[0])] = d(pair[1])
        
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
        if @model[action[0]] then @renderSubView name, property: @model, model: @model[action[0]].get subid
        # Else get it from the server.
        else (new Parse.Query(node)).get subid, success: (submodel) => @renderSubView name, property: @model, model: submodel


    renderSubView: (name, vars) =>
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass 'in'
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars).render()
        @delegateEvents()
        @$('.content').addClass 'in'
  
    # Re-render the contents of the property item.
    refresh: ->
      $('#preview-profile-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      Parse.User.current().properties.trigger "close"
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
          beforeSend: (event, files, index, xhr, handler, callBack) ->
            event.setRequestHeader "X-Parse-Application-Id", "6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO"
            event.setRequestHeader "X-Parse-REST-API-Key"  , "qgfCjwKVtDGiIKHxQmojnhoIsID7dcTHnYWZ0cf1"
          send: (e, data) ->
            delete data.headers['Content-Disposition']; # Parse does not accept this header.
          done: (e, data) ->
            file = data.result
            _this.model.save image_thumb: file.url, image_profile: file.url, image_full: file.url
            $('#edit-profile-picture-modal').modal('hide')
                
        $('#edit-profile-picture-modal').modal()
        