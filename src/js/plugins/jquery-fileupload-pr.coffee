#
# * jQuery File Upload User Interface Plugin 7.3
# * https://github.com/blueimp/jQuery-File-Upload
# *
# * Copyright 2010, Sebastian Tschan
# * https://blueimp.net
# *
# * Licensed under the MIT license:
# * http://www.opensource.org/licenses/MIT
# 

#jslint nomen: true, unparam: true, regexp: true 

#global define, window, URL, webkitURL, FileReader 
((factory) ->
  "use strict"
  if typeof define is "function" and define.amd
    
    # Register as an anonymous AMD module:
    define ["jquery", "load-image", "i18n!nls/common", "./jquery.fileupload-fp"], factory
  else
    
    # Browser globals:
    factory window.jQuery, window.loadImage
) ($, loadImage, i18nCommon) ->
  "use strict"
  
  # The UI version extends the file upload widget
  # and adds complete user interface interaction:
  $.widget "blueimp.fileupload", $.blueimp.fileupload,
    options:
      
      # By default, files added to the widget are uploaded as soon
      # as the user clicks on the start buttons. To enable automatic
      # uploads, set the following option to true:
      autoUpload: false
      
      # The following option limits the number of files that are
      # allowed to be uploaded using this widget:
      maxNumberOfFiles: 9
      
      # The maximum allowed file size:
      maxFileSize: 4000000 # 4MB
      
      # The minimum allowed file size:
      minFileSize: `undefined`
      
      # The regular expression for allowed file types, matches
      # against either file type or file name:
      acceptFileTypes: /.+$/i
      
      # The regular expression to define for which files a preview
      # image is shown, matched against the file type:
      previewSourceFileTypes: /^image\/(gif|jpe?g|png)$/
      
      # The maximum file size of images that are to be displayed as preview:
      previewSourceMaxFileSize: 5000000 # 5MB

      # The maximum width of the preview images:
      previewMaxWidth: 370
      
      # The maximum height of the preview images:
      previewMaxHeight: 500
      
      # By default, preview images are displayed as canvas elements
      # if supported by the browser. Set the following option to false
      # to always display preview images as img elements:
      previewAsCanvas: true
      
      # The ID of the upload template:
      # uploadTemplateId: "template-upload"
      
      # The ID of the download template:
      # downloadTemplateId: "template-download"
      
      # The container for the list of files. If undefined, it is set to
      # an element with class "files" inside of the widget element:
      filesContainer: `undefined`
      
      # By default, files are appended to the files container.
      # Set the following option to true, to prepend files instead:
      prependFiles: false
      
      # The expected data type of the upload response, sets the dataType
      # option of the $.ajax upload requests:
      dataType: "json"
      
      # The add callback is invoked as soon as files are added to the fileupload
      # widget (via file input selection, drag & drop or add API call).
      # See the basic file upload widget for more information:
      add: (e, data) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        that._trigger "photo:add", e, data
        options = that.options
        files = data.files
        $(this).fileupload("process", data).done ->
          that._adjustMaxNumberOfFiles -files.length
          data.maxNumberOfFilesAdjusted = true
          data.files.valid = data.isValidated = that._validate(files)
          data.context = that._renderUpload(files).data("data", data)
          options.filesContainer[(if options.prependFiles then "prepend" else "append")] data.context
          that._renderPreviews data
          that._forceReflow data.context
          that._transition(data.context).done ->
            data.submit()  if (that._trigger("added", e, data) isnt false) and (options.autoUpload or data.autoUpload) and data.autoUpload isnt false and data.isValidated

      # Callback for the start of each file upload request:
      send: (e, data) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        unless data.isValidated
          unless data.maxNumberOfFilesAdjusted
            that._adjustMaxNumberOfFiles -data.files.length
            data.maxNumberOfFilesAdjusted = true
          return false  unless that._validate(data.files)
        
        # Iframe Transport does not support progress events.
        # In lack of an indeterminate progress bar, we set
        # the progress to 100%, showing the full animated bar:
        data.context.find(".progress").addClass(not $.support.transition and "progress-animated").attr("aria-valuenow", 100).find(".bar").css "width", "100%"  if data.context and data.dataType and data.dataType.substr(0, 6) is "iframe"
        that._trigger "sent", e, data

      
      # Callback for successful uploads:
      done: (e, data) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        files = that._getFilesFromResponse(data)
        template = undefined
        deferred = undefined
        if data.context
          data.context.each (index) ->
            file = files[index] or error: "Empty file upload result"
            deferred = that._addFinishedDeferreds()
            that._adjustMaxNumberOfFiles 1  if file.error
            that._transition($(this)).done ->
              node = $(this)
              template = that._renderDownload([file]).replaceAll(node)
              that._forceReflow template
              that._transition(template).done ->
                data.context = $(this)
                that._trigger "completed", e, data
                that._trigger "finished", e, data
                deferred.resolve()
        else
          if files.length
            $.each files, (index, file) ->
              if data.maxNumberOfFilesAdjusted and file.error
                that._adjustMaxNumberOfFiles 1
              else that._adjustMaxNumberOfFiles -1  if not data.maxNumberOfFilesAdjusted and not file.error

            data.maxNumberOfFilesAdjusted = true
          template = that._renderDownload(files).appendTo(that.options.filesContainer)
          that._forceReflow template
          deferred = that._addFinishedDeferreds()
          that._transition(template).done ->
            data.context = $(this)
            that._trigger "completed", e, data
            that._trigger "finished", e, data
            deferred.resolve()


      
      # Callback for failed (abort or error) uploads:
      fail: (e, data) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        template = undefined
        deferred = undefined
        that._adjustMaxNumberOfFiles data.files.length  if data.maxNumberOfFilesAdjusted
        if data.context
          data.context.each (index) ->
            if data.errorThrown isnt "abort"
              file = data.files[index]
              file.error = file.error or data.errorThrown or true
              deferred = that._addFinishedDeferreds()
              that._transition($(this)).done ->
                node = $(this)
                template = that._renderDownload([file]).replaceAll(node)
                that._forceReflow template
                that._transition(template).done ->
                  data.context = $(this)
                  that._trigger "failed", e, data
                  that._trigger "finished", e, data
                  deferred.resolve()


            else
              deferred = that._addFinishedDeferreds()
              that._transition($(this)).done ->
                $(this).remove()
                that._trigger "failed", e, data
                that._trigger "finished", e, data
                deferred.resolve()


        else if data.errorThrown isnt "abort"
          data.context = that._renderUpload(data.files).appendTo(that.options.filesContainer).data("data", data)
          that._forceReflow data.context
          deferred = that._addFinishedDeferreds()
          that._transition(data.context).done ->
            data.context = $(this)
            that._trigger "failed", e, data
            that._trigger "finished", e, data
            deferred.resolve()

        else
          that._trigger "failed", e, data
          that._trigger "finished", e, data
          that._addFinishedDeferreds().resolve()

      
      # Callback for upload progress events:
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find(".progress").attr("aria-valuenow", progress).find(".bar").css "width", progress + "%"

      
      # Callback for global upload progress events:
      progressall: (e, data) ->
        $this = $(this)
        progress = parseInt(data.loaded / data.total * 100, 10)
        globalProgressNode = $this.find(".fileupload-progress")
        extendedProgressNode = globalProgressNode.find(".progress-extended")
        extendedProgressNode.html ($this.data("blueimp-fileupload") or $this.data("fileupload"))._renderExtendedProgress(data)  if extendedProgressNode.length
        globalProgressNode.find(".progress").attr("aria-valuenow", progress).find(".bar").css "width", progress + "%"

      
      # Callback for uploads start, equivalent to the global ajaxStart event:
      start: (e) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        that._resetFinishedDeferreds()
        that._transition($(this).find(".fileupload-progress").removeClass('hide')).done ->
          that._trigger "started", e


      
      # Callback for uploads stop, equivalent to the global ajaxStop event:
      stop: (e) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        deferred = that._addFinishedDeferreds()
        $.when.apply($, that._getFinishedDeferreds()).done ->
          that._trigger "stopped", e

        that._transition($(this).find(".fileupload-progress").addClass('hide')).done ->
          $(this).find(".progress").attr("aria-valuenow", "0").find(".bar").css "width", "0%"
          $(this).find(".progress-extended").html "&nbsp;"
          deferred.resolve()
          $(this).find(".fileupload-progress")
        that._trigger "photo:remove", e


      
      # Callback for file deletion:
      destroy: (e, data) ->
        that = $(this).data("blueimp-fileupload") or $(this).data("fileupload")
        if data.url
          $.ajax data
          that._adjustMaxNumberOfFiles 1
        that._transition(data.context).done ->
          $(this).remove()
          that._trigger "destroyed", e, data
        that._trigger "photo:remove", e, data
          


    _resetFinishedDeferreds: ->
      @_finishedUploads = []

    _addFinishedDeferreds: (deferred) ->
      deferred = $.Deferred()  unless deferred
      @_finishedUploads.push deferred
      deferred

    _getFinishedDeferreds: ->
      @_finishedUploads

    _getFilesFromResponse: (data) ->
      return data.result.files  if data.result and $.isArray(data.result.files)
      []

    
    # Link handler, that allows to download files
    # by drag & drop of the links to the desktop:
    _enableDragToDesktop: ->
      link = $(this)
      url = link.prop("href")
      name = link.prop("download")
      type = "application/octet-stream"
      link.bind "dragstart", (e) ->
        try
          e.originalEvent.dataTransfer.setData "DownloadURL", [type, name, url].join(":")


    _adjustMaxNumberOfFiles: (operand) ->
      if typeof @options.maxNumberOfFiles is "number"
        @options.maxNumberOfFiles += operand
        if @options.maxNumberOfFiles < 1
          @_disableFileInputButton()
        else
          @_enableFileInputButton()

    _formatFileSize: (bytes) ->
      return ""  if typeof bytes isnt "number"
      return (bytes / 1000000000).toFixed(2) + " GB"  if bytes >= 1000000000
      return (bytes / 1000000).toFixed(2) + " MB"  if bytes >= 1000000
      (bytes / 1000).toFixed(2) + " KB"

    _formatBitrate: (bits) ->
      return ""  if typeof bits isnt "number"
      return (bits / 1000000000).toFixed(2) + " Gbit/s"  if bits >= 1000000000
      return (bits / 1000000).toFixed(2) + " Mbit/s"  if bits >= 1000000
      return (bits / 1000).toFixed(2) + " kbit/s"  if bits >= 1000
      bits.toFixed(2) + " bit/s"

    _formatTime: (seconds) ->
      date = new Date(seconds * 1000)
      days = parseInt(seconds / 86400, 10)
      days = (if days then days + "d " else "")
      days + ("0" + date.getUTCHours()).slice(-2) + ":" + ("0" + date.getUTCMinutes()).slice(-2) + ":" + ("0" + date.getUTCSeconds()).slice(-2)

    _formatPercentage: (floatValue) ->
      (floatValue * 100).toFixed(2) + " %"

    _renderExtendedProgress: (data) ->
      @_formatBitrate(data.bitrate) + " | " + @_formatTime((data.total - data.loaded) * 8 / data.bitrate) + " | " + @_formatPercentage(data.loaded / data.total) + " | " + @_formatFileSize(data.loaded) + " / " + @_formatFileSize(data.total)

    _hasError: (file) ->
      return file.error  if file.error
      
      # The number of added files is subtracted from
      # maxNumberOfFiles before validation, so we check if
      # maxNumberOfFiles is below 0 (instead of below 1):
      return "Maximum number of files exceeded"  if @options.maxNumberOfFiles < 0
      
      # Files are accepted if either the file type or the file name
      # matches against the acceptFileTypes regular expression, as
      # only browsers with support for the File API report the type:
      return "Filetype not allowed"  unless @options.acceptFileTypes.test(file.type) or @options.acceptFileTypes.test(file.name)
      return "File is too big"  if @options.maxFileSize and file.size > @options.maxFileSize
      return "File is too small"  if typeof file.size is "number" and file.size < @options.minFileSize
      null

    _validate: (files) ->
      that = this
      valid = !!files.length
      $.each files, (index, file) ->
        file.error = that._hasError(file)
        valid = false  if file.error

      valid

    _renderTemplate: (func, files) ->
      return $()  unless func
      result = func(
        files: files
        formatFileSize: @_formatFileSize
        options: @options
        i18nCommon: i18nCommon
      )
      return result  if result instanceof $
      $(@options.templatesContainer).html(result).children()

    _renderPreview: (file, node) ->
      that = this
      options = @options
      dfd = $.Deferred()
      # If the element is not part of the DOM,
      # transition events are not triggered,
      # so we have to resolve manually:
      ((loadImage and loadImage(file, (img) ->
        img.className = 'profile-picture col-md-4'
        node.append img
        options.nameContainer.html file.name if options.nameContainer 
        that._forceReflow node
        that._transition(node).done ->
          dfd.resolveWith node

        dfd.resolveWith node  unless $.contains(that.document[0].body, node[0])
      ,
        maxWidth: options.previewMaxWidth
        maxHeight: options.previewMaxHeight
        canvas: options.previewAsCanvas
      )) or dfd.resolveWith(node)) and dfd

    _renderPreviews: (data) ->
      that = this
      options = @options
      element = data.context
        
      file = data.files[0]
      if options.previewSourceFileTypes.test(file.type) and ($.type(options.previewSourceMaxFileSize) isnt "number" or file.size < options.previewSourceMaxFileSize)
        that._processingQueue = that._processingQueue.pipe(->
          dfd = $.Deferred()
          ev = $.Event("previewdone",
            target: element
          )
          that._renderPreview(file, element).done ->
            that._trigger ev.type, ev, data
            dfd.resolveWith that

          dfd.promise()
        )

      @_processingQueue

    _renderUpload: (files) ->
      $('#preview-profile-picture').html ''
      # @_renderTemplate @options.uploadTemplate, files

    _renderDownload: (files) ->
      @_renderTemplate(@options.downloadTemplate, files).find("a[download]").each(@_enableDragToDesktop).end()

    _startHandler: (e) ->
      e.preventDefault()
      button = $(e.currentTarget)
      template = $('#preview-profile-picture')
      data = template.data("data")
      button.prop "disabled", true  if data and data.submit and not data.jqXHR and data.submit()

    _cancelHandler: (e) ->
      e.preventDefault()
      template = $(e.currentTarget).closest(".template-upload")
      data = template.data("data") or {}
      unless data.jqXHR
        data.errorThrown = "abort"
        @_trigger "fail", e, data
      else
        data.jqXHR.abort()

    _deleteHandler: (e) ->
      e.preventDefault()
      button = $(e.currentTarget)
      @_trigger "destroy", e, $.extend(
        context: button.closest(".template-download")
        type: "DELETE"
        dataType: @options.dataType
      , button.data())

    _forceReflow: (node) ->
      $.support.transition and node.length and node[0].offsetWidth

    _transition: (node) ->
      dfd = $.Deferred()
      if $.support.transition and node.hasClass("fade")
        
        # Make sure we don't respond to other transitions events
        # in the container element, e.g. from button elements:
        node.bind($.support.transition.end, (e) ->
          if e.target is node[0]
            node.unbind $.support.transition.end
            dfd.resolveWith node
        ).toggleClass "in"
      else
        node.toggleClass "in"
        dfd.resolveWith node
      dfd

    _initButtonBarEventHandlers: ->
      fileUploadButtonBar = @element.find(".fileupload-buttonbar")
      filesList = @options.filesContainer
      @_on fileUploadButtonBar.find(".start"),
        click: (e) ->
          e.preventDefault()
          filesList.find(".start").click()

      @_on fileUploadButtonBar.find(".cancel"),
        click: (e) ->
          e.preventDefault()
          filesList.find(".cancel").click()

      @_on fileUploadButtonBar.find(".delete"),
        click: (e) ->
          e.preventDefault()
          filesList.find(".delete input:checked").siblings("button").click()
          fileUploadButtonBar.find(".toggle").prop "checked", false

      @_on fileUploadButtonBar.find(".toggle"),
        change: (e) ->
          filesList.find(".delete input").prop "checked", $(e.currentTarget).is(":checked")


    _destroyButtonBarEventHandlers: ->
      @_off @element.find(".fileupload-buttonbar button"), "click"
      @_off @element.find(".fileupload-buttonbar .toggle"), "change."

    _initEventHandlers: ->
      @_super()
      @_on @element,
        "click .start": @_startHandler
        "click .cancel": @_cancelHandler

      # @_initButtonBarEventHandlers()

    _destroyEventHandlers: ->
      @_destroyButtonBarEventHandlers()
      @_off @options.filesContainer, "click"
      @_super()

    _enableFileInputButton: ->
      @element.find(".fileinput-button input").prop("disabled", false).parent().removeClass "disabled"

    _disableFileInputButton: ->
      @element.find(".fileinput-button input").prop("disabled", true).parent().addClass "disabled"

    _initTemplates: ->
      options = @options
      options.templatesContainer = @document[0].createElement(options.filesContainer.prop("nodeName"))

      options.uploadTemplate = JST["src/js/templates/photo/pending.jst"]
      options.downloadTemplate = JST["src/js/templates/file/download.jst"]

    _initFilesContainer: ->
      options = @options
      if options.filesContainer is `undefined`
        options.filesContainer = @element.find(".files")
      else options.filesContainer = $(options.filesContainer)  unless options.filesContainer instanceof $

    _stringToRegExp: (str) ->
      parts = str.split("/")
      modifiers = parts.pop()
      parts.shift()
      new RegExp(parts.join("/"), modifiers)

    _initRegExpOptions: ->
      options = @options
      options.acceptFileTypes = @_stringToRegExp(options.acceptFileTypes)  if $.type(options.acceptFileTypes) is "string"
      options.previewSourceFileTypes = @_stringToRegExp(options.previewSourceFileTypes)  if $.type(options.previewSourceFileTypes) is "string"

    _initSpecialOptions: ->
      @_super()
      @_initFilesContainer()
      @_initTemplates()
      @_initRegExpOptions()

    _setOption: (key, value) ->
      @_super key, value
      @_adjustMaxNumberOfFiles 0  if key is "maxNumberOfFiles"

    _create: ->
      @_super()
      @_refreshOptionsList.push "filesContainer" # , "uploadTemplateId", "downloadTemplateId"
      unless @_processingQueue
        @_processingQueue = $.Deferred().resolveWith(this).promise()
        @process = ->
          @_processingQueue
      @_resetFinishedDeferreds()

    enable: ->
      wasDisabled = false
      wasDisabled = true  if @options.disabled
      @_super()
      if wasDisabled
        @element.find("input, button").prop "disabled", false
        @_enableFileInputButton()

    disable: ->
      unless @options.disabled
        @element.find("input, button").prop "disabled", true
        @_disableFileInputButton()
      @_super()

