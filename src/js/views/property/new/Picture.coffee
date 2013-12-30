define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/new/picture'
  'jquery.fileupload'
  'jquery.fileupload-fp'
  'jquery.fileupload-pr'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PicturePropertyView extends Parse.View

    tagName : "form"
    id: "new-property-picture-form"
    className: "col-xs-12"

    events:
      "click .delete" : "resetImage"
    
    initialize: (attrs) ->
      
      @wizard = attrs.wizard
      
      @listenTo @wizard, "wizard:finish wizard:cancel", @clear

    # Re-render the contents of the property item.
    render: ->
      vars = _.merge @model.toJSON(),
        profile: @model.get("profile").toJSON()
        publicUrl: @model.publicUrl()
        cover: @model.get("profile").cover 'full'
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      
      @$el.html JST["src/js/templates/property/new/picture.jst"](vars)

      # _this = @ # Keep for below

      # Initiate the file upload.
      @$el.fileupload
        autoUpload: true
        type: "POST"
        dataType: "json"
        # fileInput: '#file-input'
        filesContainer: _this.$('#preview-profile-picture')
        multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
        context: @$el
        add: (e, data) ->
          data.submit()
        submit: (e, data) ->
          data.url = "https://api.parse.com/1/files/" + data.files[0].name
        send: (e, data) ->
          delete data.headers['Content-Disposition']; # Parse does not accept this header.
        done: (e, data) =>
          file = data.result
          @model.get("profile").set image_thumb: file.url, image_profile: file.url, image_full: file.url
          @$('#preview-profile-picture img').prop('src', file.url)
          @$(".delete").removeClass("hide")

      @
    
    resetImage: =>
      @model.get("profile").set image_thumb: null, image_profile: null, image_full: null
      @$('#preview-profile-picture img').prop('src', "/img/fallback/property-large.png")
      @$(".delete").addClass("hide")

    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this