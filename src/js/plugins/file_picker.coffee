define [
  "jquery"
  "underscore" 
], ($, _) ->

  $.fn.filePicker = ->
    
    file = undefined

    fileSelectHandler = (e) ->
      files = e.target.files or e.dataTransfer.files
      file = files[0]
      previewFile()
  
    upload = (e) ->
      e.preventDefault()
      return unless file?
      serverUrl = "https://api.parse.com/1/files/" + file.name
      $.ajax
        type: "POST"
        beforeSend: (request) ->
          request.setRequestHeader "X-Parse-Application-Id", "6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO"
          request.setRequestHeader "X-Parse-REST-API-Key", "qgfCjwKVtDGiIKHxQmojnhoIsID7dcTHnYWZ0cf1"
          request.setRequestHeader "Content-Type", file.type

        url: serverUrl
        data: file
        processData: false
        contentType: false
        success: (data) ->
          
          # save result from Parse local storage, so we can use it later
          localStorage.setItem "parse_file_name", data.name
          localStorage.setItem "parse_url", data.url
      
          # this is actual file name we uploaded, which is different from name Parse sends us bak
          localStorage.setItem "file_name", file.name

    
        # OPTIONAL: add service to save file name/URL to a list
        error: (data) ->
          obj = jQuery.parseJSON(data)
          alert obj.error

    previewFile = =>
      previewContainer = $(@prop("data-preview"))
      
      # make the preview container visible once a file was selected
      previewContainer.toggle()
      
      # set the file name beside the image
      fileName = $("[name=fileName]")
      
      if fileName?
        
        fileName.text file.name
        
        # display image in preview container
        if file.type.indexOf("image") is 0
          reader = new FileReader()
          reader.onload = (e) ->
            image = $("[name=image]")
            image.attr "src", e.target.result
            $("[class=mobileimage1_div]").show()
      
          reader.readAsDataURL file

    #  Init
    @bind "change", fileSelectHandler
    $(@data('button')).bind "click", upload
    this