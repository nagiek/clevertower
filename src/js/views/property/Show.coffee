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
  
    tagName: "div"
    id: "property"
    
    events:
      'click .edit-profile-picture': 'editProfilePicture'
      'click h1 a': 'changeSubView'
      'click .nav .dropdown-menu a': 'changeSubView'
      'click .content a': 'changeSubView'

    initialize: (attrs) ->
      
      # Bind this outside of events, as it is not with $el
      $('.home').on 'click', @clear
            
      @$form = $("#profile-picture-upload")
      
      @model.on 'change:image_profile', (model, name) => @refresh
      @model.on 'destroy',  @clear
      
      @changeSubView attrs.e

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

    changeSubView: (e) =>
      
      origSubViewName = @subViewName

      # Remove the leading "/" and split into components
      urlComponents = e.currentTarget.pathname.substring(1).split("/")
      action = if urlComponents.length > 2 then urlComponents.slice(2) else new Array('units')
            
      if action.length > 1 and action[0] isnt "add"
        # Subnode view
        node = inflection.singularize[action[0]]
        subaction = if action[2] then action[2] else "show"
        vars = property: @model, subId: action[1]
        @subViewName = "views/#{node}/#{subaction}"
      else      
        # Property view
        @model.loadUnits() if action[0] is "add"
        vars = model: @model
        @subViewName = "views/property/sub/#{action.join("/")}"
      
      return if @subViewName is origSubViewName
      
      # Get the query string, if it exists.
      querystring = e.currentTarget.search
      if querystring.length > 0
        # Remove the leading "?" and split into components
        queryComponents = querystring.substring(1).split('&')
        vars.params = {}
        d = decodeURIComponent
        # march and parse
        for combo in queryComponents
          pair = combo.split('=')
          vars.params[d(pair[0])] = d(pair[1])
      
      @renderSubView(vars) 

    renderSubView: (vars) =>
      if @subView
        @subView.trigger "view:change" 
      
      require [@subViewName], (PropertySubView) =>
        @subView = new PropertySubView(vars)
        @subView.render()
        @delegateEvents()
  
    # Re-render the contents of the property item.
    refresh: ->
      $('#preview-profile-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      @model.collection.trigger "close"
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
        