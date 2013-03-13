#
# * jQuery File Upload File Processing Plugin 1.2.1
# * https://github.com/blueimp/jQuery-File-Upload
# *
# * Copyright 2012, Sebastian Tschan
# * https://blueimp.net
# *
# * Licensed under the MIT license:
# * http://www.opensource.org/licenses/MIT
# 

#jslint nomen: true, unparam: true, regexp: true 

#global define, window, document 
((factory) ->
  "use strict"
  if typeof define is "function" and define.amd
    
    # Register as an anonymous AMD module:
    define ["jquery", "load-image", "canvas-to-blob", "./jquery.fileupload"], factory
  else
    
    # Browser globals:
    factory window.jQuery, window.loadImage
) ($, loadImage) ->
  "use strict"
  
  # The File Upload FP version extends the fileupload widget
  # with file processing functionality:
  $.widget "blueimp.fileupload", $.blueimp.fileupload,
    options:
      
      # The list of file processing actions:
      process: []
      
      #
      #                {
      #                    action: 'load',
      #                    fileTypes: /^image\/(gif|jpeg|png)$/,
      #                    maxFileSize: 20000000 // 20MB
      #                },
      #                {
      #                    action: 'resize',
      #                    maxWidth: 1920,
      #                    maxHeight: 1200,
      #                    minWidth: 800,
      #                    minHeight: 600
      #                },
      #                {
      #                    action: 'save'
      #                }
      #            
      
      # The add callback is invoked as soon as files are added to the
      # fileupload widget (via file input selection, drag & drop or add
      # API call). See the basic file upload widget for more information:
      add: (e, data) ->
        $(this).fileupload("process", data).done ->
          data.submit()


    processActions:
      
      # Loads the image given via data.files and data.index
      # as img element if the browser supports canvas.
      # Accepts the options fileTypes (regular expression)
      # and maxFileSize (integer) to limit the files to load:
      load: (data, options) ->
        that = this
        file = data.files[data.index]
        dfd = $.Deferred()
        if window.HTMLCanvasElement and window.HTMLCanvasElement::toBlob and ($.type(options.maxFileSize) isnt "number" or file.size < options.maxFileSize) and (not options.fileTypes or options.fileTypes.test(file.type))
          loadImage file, (img) ->
            return dfd.rejectWith(that, [data])  unless img.src
            data.img = img
            dfd.resolveWith that, [data]

        else
          dfd.rejectWith that, [data]
        dfd.promise()

      
      # Resizes the image given as data.img and updates
      # data.canvas with the resized image as canvas element.
      # Accepts the options maxWidth, maxHeight, minWidth and
      # minHeight to scale the given image:
      resize: (data, options) ->
        img = data.img
        canvas = undefined
        options = $.extend(
          canvas: true
        , options)
        if img
          canvas = loadImage.scale(img, options)
          data.canvas = canvas  if canvas.width isnt img.width or canvas.height isnt img.height
        data

      
      # Saves the processed image given as data.canvas
      # inplace at data.index of data.files:
      save: (data, options) ->
        
        # Do nothing if no processing has happened:
        return data  unless data.canvas
        that = this
        file = data.files[data.index]
        name = file.name
        dfd = $.Deferred()
        callback = (blob) ->
          unless blob.name
            if file.type is blob.type
              blob.name = file.name
            else blob.name = file.name.replace(/\..+$/, "." + blob.type.substr(6))  if file.name
          
          # Store the created blob at the position
          # of the original file in the files list:
          data.files[data.index] = blob
          dfd.resolveWith that, [data]

        
        # Use canvas.mozGetAsFile directly, to retain the filename, as
        # Gecko doesn't support the filename option for FormData.append:
        if data.canvas.mozGetAsFile
          callback data.canvas.mozGetAsFile((/^image\/(jpeg|png)$/.test(file.type) and name) or ((name and name.replace(/\..+$/, "")) or "blob") + ".png", file.type)
        else
          data.canvas.toBlob callback, file.type
        dfd.promise()

    
    # Resizes the file at the given index and stores the created blob at
    # the original position of the files list, returns a Promise object:
    _processFile: (files, index, options) ->
      that = this
      dfd = $.Deferred().resolveWith(that, [
        files: files
        index: index
      ])
      chain = dfd.promise()
      that._processing += 1
      $.each options.process, (i, settings) ->
        chain = chain.pipe((data) ->
          that.processActions[settings.action].call this, data, settings
        )

      chain.always ->
        that._processing -= 1
        that.element.removeClass "fileupload-processing"  if that._processing is 0

      that.element.addClass "fileupload-processing"  if that._processing is 1
      chain

    
    # Processes the files given as files property of the data parameter,
    # returns a Promise object that allows to bind a done handler, which
    # will be invoked after processing all files (inplace) is done:
    process: (data) ->
      that = this
      options = $.extend({}, @options, data)
      if options.process and options.process.length and @_isXHRUpload(options)
        $.each data.files, (index, file) ->
          that._processingQueue = that._processingQueue.pipe(->
            dfd = $.Deferred()
            that._processFile(data.files, index, options).always ->
              dfd.resolveWith that

            dfd.promise()
          )

      @_processingQueue

    _create: ->
      @_super()
      @_processing = 0
      @_processingQueue = $.Deferred().resolveWith(this).promise()

