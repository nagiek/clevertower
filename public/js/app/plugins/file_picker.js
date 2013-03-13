(function() {

  define(["jquery", "underscore"], function($, _) {
    return $.fn.filePicker = function() {
      var file, fileSelectHandler, previewFile, upload,
        _this = this;
      file = void 0;
      fileSelectHandler = function(e) {
        var files;
        files = e.target.files || e.dataTransfer.files;
        file = files[0];
        return previewFile();
      };
      upload = function(e) {
        var serverUrl;
        e.preventDefault();
        if (file == null) {
          return;
        }
        serverUrl = "https://api.parse.com/1/files/" + file.name;
        return $.ajax({
          type: "POST",
          beforeSend: function(request) {
            request.setRequestHeader("X-Parse-Application-Id", "6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO");
            request.setRequestHeader("X-Parse-REST-API-Key", "qgfCjwKVtDGiIKHxQmojnhoIsID7dcTHnYWZ0cf1");
            return request.setRequestHeader("Content-Type", file.type);
          },
          url: serverUrl,
          data: file,
          processData: false,
          contentType: false,
          success: function(data) {
            console.log(data);
            localStorage.setItem("parse_file_name", data.name);
            localStorage.setItem("parse_url", data.url);
            return localStorage.setItem("file_name", file.name);
          },
          error: function(data) {
            var obj;
            obj = jQuery.parseJSON(data);
            return alert(obj.error);
          }
        });
      };
      previewFile = function() {
        var fileName, previewContainer, reader;
        previewContainer = $(_this.prop("data-preview"));
        previewContainer.toggle();
        fileName = $("[name=fileName]");
        if (fileName != null) {
          fileName.text(file.name);
          if (file.type.indexOf("image") === 0) {
            reader = new FileReader();
            reader.onload = function(e) {
              var image;
              image = $("[name=image]");
              image.attr("src", e.target.result);
              return $("[class=mobileimage1_div]").show();
            };
            return reader.readAsDataURL(file);
          }
        }
      };
      this.bind("change", fileSelectHandler);
      $(this.data('button')).bind("click", upload);
      return this;
    };
  });

}).call(this);
