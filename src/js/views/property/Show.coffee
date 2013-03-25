define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  'views/helper/Inflection'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/show'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/other"
  "templates/property/menu/actions"
], ($, _, Parse, Property, Inflection, i18nProperty, i18nCommon) ->

  class PropertyView extends Parse.View
  
    el: "#property"
    
    events:
      'click #edit-profile-picture': 'editProfilePicture'

    initialize: (attrs) ->
      if attrs.action.indexOf("/") > 0 and attrs.action.indexOf("add") isnt 0
        # Subnode view
        combo = attrs.action.split("/")
        @vars = property: @model, subId: combo[1]
        node = Inflection.singularize[combo[0]]
        subaction = if combo[2] then combo[2] else "show"
        @subView = "views/#{node}/#{subaction}"
      else
        # Property view
        @vars = model: @model
        @model.loadUnits() if attrs.action is 'add/lease'
        @subView = "views/property/sub/#{attrs.action}"
        
      @vars.params = attrs.params if attrs.params
      
      collections = 
        cover        : @model.cover('profile')
        units        : if @model.units    then String @model.units.length                         else '0'
        tasks        : if @model.tasks    then String @model.tasks.length                         else '0'
        incomes      : if @model.incomes  then String @model.incomes.length                       else '0'
        expenses     : if @model.expenses then String @model.expenses.length                      else '0'
        vacant_units : '0'
        # collection.where not defined yet
        # vacant_units : if @model.units    then String @model.units.where(occupied: false).length  else '0'
      
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
      require [@subView], (PropertySubView) =>
        propertyView = new PropertySubView(@vars)
      @
  
    # Re-render the contents of the property item.
    refresh: ->
      $('#preview-profile-picture img').prop('src', @model.cover('profile'))
      
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
        