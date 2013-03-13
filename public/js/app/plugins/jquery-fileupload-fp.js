(function() {

  (function(factory) {
    "use strict";
    if (typeof define === "function" && define.amd) {
      return define(["jquery", "load-image", "canvas-to-blob", "./jquery.fileupload"], factory);
    } else {
      return factory(window.jQuery, window.loadImage);
    }
  })(function($, loadImage) {
    "use strict";
    return $.widget("blueimp.fileupload", $.blueimp.fileupload, {
      options: {
        process: [],
        add: function(e, data) {
          return $(this).fileupload("process", data).done(function() {
            return data.submit();
          });
        }
      },
      processActions: {
        load: function(data, options) {
          var dfd, file, that;
          that = this;
          file = data.files[data.index];
          dfd = $.Deferred();
          if (window.HTMLCanvasElement && window.HTMLCanvasElement.prototype.toBlob && ($.type(options.maxFileSize) !== "number" || file.size < options.maxFileSize) && (!options.fileTypes || options.fileTypes.test(file.type))) {
            loadImage(file, function(img) {
              if (!img.src) {
                return dfd.rejectWith(that, [data]);
              }
              data.img = img;
              return dfd.resolveWith(that, [data]);
            });
          } else {
            dfd.rejectWith(that, [data]);
          }
          return dfd.promise();
        },
        resize: function(data, options) {
          var canvas, img;
          img = data.img;
          canvas = void 0;
          options = $.extend({
            canvas: true
          }, options);
          if (img) {
            canvas = loadImage.scale(img, options);
            if (canvas.width !== img.width || canvas.height !== img.height) {
              data.canvas = canvas;
            }
          }
          return data;
        },
        save: function(data, options) {
          var callback, dfd, file, name, that;
          if (!data.canvas) {
            return data;
          }
          that = this;
          file = data.files[data.index];
          name = file.name;
          dfd = $.Deferred();
          callback = function(blob) {
            if (!blob.name) {
              if (file.type === blob.type) {
                blob.name = file.name;
              } else {
                if (file.name) {
                  blob.name = file.name.replace(/\..+$/, "." + blob.type.substr(6));
                }
              }
            }
            data.files[data.index] = blob;
            return dfd.resolveWith(that, [data]);
          };
          if (data.canvas.mozGetAsFile) {
            callback(data.canvas.mozGetAsFile((/^image\/(jpeg|png)$/.test(file.type) && name) || ((name && name.replace(/\..+$/, "")) || "blob") + ".png", file.type));
          } else {
            data.canvas.toBlob(callback, file.type);
          }
          return dfd.promise();
        }
      },
      _processFile: function(files, index, options) {
        var chain, dfd, that;
        that = this;
        dfd = $.Deferred().resolveWith(that, [
          {
            files: files,
            index: index
          }
        ]);
        chain = dfd.promise();
        that._processing += 1;
        $.each(options.process, function(i, settings) {
          return chain = chain.pipe(function(data) {
            return that.processActions[settings.action].call(this, data, settings);
          });
        });
        chain.always(function() {
          that._processing -= 1;
          if (that._processing === 0) {
            return that.element.removeClass("fileupload-processing");
          }
        });
        if (that._processing === 1) {
          that.element.addClass("fileupload-processing");
        }
        return chain;
      },
      process: function(data) {
        var options, that;
        that = this;
        options = $.extend({}, this.options, data);
        if (options.process && options.process.length && this._isXHRUpload(options)) {
          $.each(data.files, function(index, file) {
            return that._processingQueue = that._processingQueue.pipe(function() {
              var dfd;
              dfd = $.Deferred();
              that._processFile(data.files, index, options).always(function() {
                return dfd.resolveWith(that);
              });
              return dfd.promise();
            });
          });
        }
        return this._processingQueue;
      },
      _create: function() {
        this._super();
        this._processing = 0;
        return this._processingQueue = $.Deferred().resolveWith(this).promise();
      }
    });
  });

}).call(this);
