define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/show'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/other"
  "templates/property/menu/actions"
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertyView extends Parse.View
  
    el: "#property"
    
    events:
      'click #edit-profile-picture': 'editProfilePicture'

    initialize: (attrs) ->
      
      @action = attrs.action
      console.log @model
      
      # Convert to collections.
      # @model.set 
      collections = 
        cover        : @model.cover('profile')

        tasks        : '0'            # @model.tasks()
        incomes      : '0'            # @model.incomes().sum()
        expenses     : '0'            # @model.expenses().sum()
        vacant_units : '0'            # @model.units().vacant().length
        units        : '0'            # @model.units().length
      
      $(@el).html JST["src/js/templates/property/show.jst"](_.merge(@model.toJSON(),collections,i18nProperty: i18nProperty, i18nCommon: i18nCommon))
      
      @$form = $("#profile-picture-upload")
      
      @model.on 'change:image_profile', (model, name) =>
        @refresh()

      @model.on 'destroy',  =>
        @remove()
        @undelegateEvents()
        delete this

      @render()

    # Re-render the contents of the property item.
    render: ->
      require ["views/property/sub/#{@action}"], (PropertySubView) =>
        propertyView = new PropertySubView(model: @model)
      this

  
    # Re-render the contents of the property item.
    refresh: ->
      $('#preview-profile-picture img').prop('src', @model.cover('profile'))
      
    editProfilePicture: ->
      
      _this = @
      
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
        