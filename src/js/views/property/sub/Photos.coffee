define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "models/Photo"
  "collections/PhotoList"
  "views/photo/Show"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/sub/photos"
  'jqueryuiwidget'
  'jquery.fileupload'
  'jquery.fileupload-fp'
  'jquery.fileupload-ui'
], ($, _, Parse, Property, Photo, PhotoList, PhotoView, i18nProperty, i18nCommon) ->

  class PropertyPhotosView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: ".content"
    
    initialize : ->
      
      @on "view:change", @clear
      
      @unUploadedPhotos = 0
          
      @photos = new PhotoList [], property: @model

      @listenTo @photos, "add", @addOne
      @listenTo @photos, "reset", @addAll

      # @on 'added', (e, data) =>
      #   @unUploadedPhotos++
      # 
      # @on "photo:upload", (file) =>
      #   @unUploadedPhotos--
      # 
      # @on "photo:remove", (e, data) =>
      #   @unUploadedPhotos--

    render : ->
      _this = this
      @$el.html JST["src/js/templates/property/sub/photos.jst"](property: @model, i18nProperty: i18nProperty, i18nCommon: i18nCommon)
      @$list = $("#photo-list")
      @$fileForm = $("#fileupload")

      uploads = []

      # Initiate the file upload.
      @$fileForm.fileupload
        autoUpload: false
        type: "POST"
        dataType: "json"
        # fileInput: '#file-input'
        filesContainer: '#non-uploaded-photo-list'
        multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
        context: @$fileForm[0]
        # The list of file processing actions:
        # For multiple resolutions see
        # https://github.com/blueimp/jQuery-File-Upload/wiki/Upload-multiple-resolutions-of-one-photo-with-multiple-resize-options
        process: [
          {
            action: 'load'
            fileTypes: /^photo\/(gif|jpe?g|png)$/
            maxFileSize: 4000000 # 4MB
          },
          {
            action: 'resize'
            maxWidth: 1920
            maxHeight: 1200
          },
          {action: 'save'},
        ]
        submit: (e, data) ->
          data.url = "https://api.parse.com/1/files/" + data.files[0].name
        send: (e, data) =>
          @$('.empty').remove()
          delete data.headers['Content-Disposition']; # Parse does not accept this header.
        done: (e, data) ->

          file = data.result

          photo = new Photo
            network: _this.model.get("network")
            property: _this.model
            url: file.url
            name: file.name

          # Defer to our photo rendering method.
          that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
          that._transition(data.context)
          
          data.context.each (index) ->
            node = $(this)
            that._transition(node).done ->
              node.remove()

          uploads.push photo.save()

        stop: (e, data) =>

          Parse.Promise.when(uploads).then =>
            @photos.add photo for photo in arguments
            Parse.Cloud.run 'AddPhotoActivity', { 
              image: arguments[0].get "name"
              length: arguments.length
              propertyId: @model.id
              # center: _this.model.get("center")
              # networkId: _this.model.get("network").id
            },
              success: (model) => Parse.App.activity.add model if Parse.App.activity
              error: (error) => console.log error

            # Reset for next photos
            uploads = []

          @$(".fileupload-progress").addClass("hide")
      
      # Fetch all the property items for this user
      @photos.fetch()
      @

    clear: (e) =>
      @undelegateEvents()
      delete @photos
      delete this

    addOne : (photo) =>
      view = new PhotoView model: photo
      @$list.append view.render().el
      
    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless @photos.length is 0
        @photos.each @addOne
      else
        @$list.before '<p class="empty">' + i18nProperty.empty.photos + '</p>'