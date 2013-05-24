(function() {
  (function(factory) {
    "use strict";    if (typeof define === "function" && define.amd) {
      return define(["jquery", "load-image", "i18n!nls/common", "./jquery.fileupload-fp"], factory);
    } else {
      return factory(window.jQuery, window.loadImage);
    }
  })(function($, loadImage, i18nCommon) {
    "use strict";    return $.widget("blueimp.fileupload", $.blueimp.fileupload, {
      options: {
        autoUpload: false,
        maxNumberOfFiles: 9,
        maxFileSize: 4000000,
        minFileSize: undefined,
        acceptFileTypes: /.+$/i,
        previewSourceFileTypes: /^image\/(gif|jpe?g|png)$/,
        previewSourceMaxFileSize: 5000000,
        previewMaxWidth: 370,
        previewMaxHeight: 500,
        previewAsCanvas: true,
        filesContainer: undefined,
        prependFiles: false,
        dataType: "json",
        add: function(e, data) {
          var files, options, that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          that._trigger("photo:add", e, data);
          options = that.options;
          files = data.files;
          return $(this).fileupload("process", data).done(function() {
            that._adjustMaxNumberOfFiles(-files.length);
            data.maxNumberOfFilesAdjusted = true;
            data.files.valid = data.isValidated = that._validate(files);
            data.context = that._renderUpload(files).data("data", data);
            options.filesContainer[(options.prependFiles ? "prepend" : "append")](data.context);
            that._renderPreviews(data);
            that._forceReflow(data.context);
            return that._transition(data.context).done(function() {
              if ((that._trigger("added", e, data) !== false) && (options.autoUpload || data.autoUpload) && data.autoUpload !== false && data.isValidated) {
                return data.submit();
              }
            });
          });
        },
        send: function(e, data) {
          var that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          if (!data.isValidated) {
            if (!data.maxNumberOfFilesAdjusted) {
              that._adjustMaxNumberOfFiles(-data.files.length);
              data.maxNumberOfFilesAdjusted = true;
            }
            if (!that._validate(data.files)) {
              return false;
            }
          }
          if (data.context && data.dataType && data.dataType.substr(0, 6) === "iframe") {
            data.context.find(".progress").addClass(!$.support.transition && "progress-animated").attr("aria-valuenow", 100).find(".bar").css("width", "100%");
          }
          return that._trigger("sent", e, data);
        },
        done: function(e, data) {
          var deferred, files, template, that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          files = that._getFilesFromResponse(data);
          template = void 0;
          deferred = void 0;
          if (data.context) {
            return data.context.each(function(index) {
              var file;

              file = files[index] || {
                error: "Empty file upload result"
              };
              deferred = that._addFinishedDeferreds();
              if (file.error) {
                that._adjustMaxNumberOfFiles(1);
              }
              return that._transition($(this)).done(function() {
                var node;

                node = $(this);
                template = that._renderDownload([file]).replaceAll(node);
                that._forceReflow(template);
                return that._transition(template).done(function() {
                  data.context = $(this);
                  that._trigger("completed", e, data);
                  that._trigger("finished", e, data);
                  return deferred.resolve();
                });
              });
            });
          } else {
            if (files.length) {
              $.each(files, function(index, file) {
                if (data.maxNumberOfFilesAdjusted && file.error) {
                  return that._adjustMaxNumberOfFiles(1);
                } else {
                  if (!data.maxNumberOfFilesAdjusted && !file.error) {
                    return that._adjustMaxNumberOfFiles(-1);
                  }
                }
              });
              data.maxNumberOfFilesAdjusted = true;
            }
            template = that._renderDownload(files).appendTo(that.options.filesContainer);
            that._forceReflow(template);
            deferred = that._addFinishedDeferreds();
            return that._transition(template).done(function() {
              data.context = $(this);
              that._trigger("completed", e, data);
              that._trigger("finished", e, data);
              return deferred.resolve();
            });
          }
        },
        fail: function(e, data) {
          var deferred, template, that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          template = void 0;
          deferred = void 0;
          if (data.maxNumberOfFilesAdjusted) {
            that._adjustMaxNumberOfFiles(data.files.length);
          }
          if (data.context) {
            return data.context.each(function(index) {
              var file;

              if (data.errorThrown !== "abort") {
                file = data.files[index];
                file.error = file.error || data.errorThrown || true;
                deferred = that._addFinishedDeferreds();
                return that._transition($(this)).done(function() {
                  var node;

                  node = $(this);
                  template = that._renderDownload([file]).replaceAll(node);
                  that._forceReflow(template);
                  return that._transition(template).done(function() {
                    data.context = $(this);
                    that._trigger("failed", e, data);
                    that._trigger("finished", e, data);
                    return deferred.resolve();
                  });
                });
              } else {
                deferred = that._addFinishedDeferreds();
                return that._transition($(this)).done(function() {
                  $(this).remove();
                  that._trigger("failed", e, data);
                  that._trigger("finished", e, data);
                  return deferred.resolve();
                });
              }
            });
          } else if (data.errorThrown !== "abort") {
            data.context = that._renderUpload(data.files).appendTo(that.options.filesContainer).data("data", data);
            that._forceReflow(data.context);
            deferred = that._addFinishedDeferreds();
            return that._transition(data.context).done(function() {
              data.context = $(this);
              that._trigger("failed", e, data);
              that._trigger("finished", e, data);
              return deferred.resolve();
            });
          } else {
            that._trigger("failed", e, data);
            that._trigger("finished", e, data);
            return that._addFinishedDeferreds().resolve();
          }
        },
        progress: function(e, data) {
          var progress;

          if (data.context) {
            progress = parseInt(data.loaded / data.total * 100, 10);
            return data.context.find(".progress").attr("aria-valuenow", progress).find(".bar").css("width", progress + "%");
          }
        },
        progressall: function(e, data) {
          var $this, extendedProgressNode, globalProgressNode, progress;

          $this = $(this);
          progress = parseInt(data.loaded / data.total * 100, 10);
          globalProgressNode = $this.find(".fileupload-progress");
          extendedProgressNode = globalProgressNode.find(".progress-extended");
          if (extendedProgressNode.length) {
            extendedProgressNode.html(($this.data("blueimp-fileupload") || $this.data("fileupload"))._renderExtendedProgress(data));
          }
          return globalProgressNode.find(".progress").attr("aria-valuenow", progress).find(".bar").css("width", progress + "%");
        },
        start: function(e) {
          var that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          that._resetFinishedDeferreds();
          return that._transition($(this).find(".fileupload-progress").removeClass('hide')).done(function() {
            return that._trigger("started", e);
          });
        },
        stop: function(e) {
          var deferred, that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          deferred = that._addFinishedDeferreds();
          $.when.apply($, that._getFinishedDeferreds()).done(function() {
            return that._trigger("stopped", e);
          });
          that._transition($(this).find(".fileupload-progress").addClass('hide')).done(function() {
            $(this).find(".progress").attr("aria-valuenow", "0").find(".bar").css("width", "0%");
            $(this).find(".progress-extended").html("&nbsp;");
            deferred.resolve();
            return $(this).find(".fileupload-progress");
          });
          return that._trigger("photo:remove", e);
        },
        destroy: function(e, data) {
          var that;

          that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
          if (data.url) {
            $.ajax(data);
            that._adjustMaxNumberOfFiles(1);
          }
          that._transition(data.context).done(function() {
            $(this).remove();
            return that._trigger("destroyed", e, data);
          });
          return that._trigger("photo:remove", e, data);
        }
      },
      _resetFinishedDeferreds: function() {
        return this._finishedUploads = [];
      },
      _addFinishedDeferreds: function(deferred) {
        if (!deferred) {
          deferred = $.Deferred();
        }
        this._finishedUploads.push(deferred);
        return deferred;
      },
      _getFinishedDeferreds: function() {
        return this._finishedUploads;
      },
      _getFilesFromResponse: function(data) {
        if (data.result && $.isArray(data.result.files)) {
          return data.result.files;
        }
        return [];
      },
      _enableDragToDesktop: function() {
        var link, name, type, url;

        link = $(this);
        url = link.prop("href");
        name = link.prop("download");
        type = "application/octet-stream";
        return link.bind("dragstart", function(e) {
          try {
            return e.originalEvent.dataTransfer.setData("DownloadURL", [type, name, url].join(":"));
          } catch (_error) {}
        });
      },
      _adjustMaxNumberOfFiles: function(operand) {
        if (typeof this.options.maxNumberOfFiles === "number") {
          this.options.maxNumberOfFiles += operand;
          if (this.options.maxNumberOfFiles < 1) {
            return this._disableFileInputButton();
          } else {
            return this._enableFileInputButton();
          }
        }
      },
      _formatFileSize: function(bytes) {
        if (typeof bytes !== "number") {
          return "";
        }
        if (bytes >= 1000000000) {
          return (bytes / 1000000000).toFixed(2) + " GB";
        }
        if (bytes >= 1000000) {
          return (bytes / 1000000).toFixed(2) + " MB";
        }
        return (bytes / 1000).toFixed(2) + " KB";
      },
      _formatBitrate: function(bits) {
        if (typeof bits !== "number") {
          return "";
        }
        if (bits >= 1000000000) {
          return (bits / 1000000000).toFixed(2) + " Gbit/s";
        }
        if (bits >= 1000000) {
          return (bits / 1000000).toFixed(2) + " Mbit/s";
        }
        if (bits >= 1000) {
          return (bits / 1000).toFixed(2) + " kbit/s";
        }
        return bits.toFixed(2) + " bit/s";
      },
      _formatTime: function(seconds) {
        var date, days;

        date = new Date(seconds * 1000);
        days = parseInt(seconds / 86400, 10);
        days = (days ? days + "d " : "");
        return days + ("0" + date.getUTCHours()).slice(-2) + ":" + ("0" + date.getUTCMinutes()).slice(-2) + ":" + ("0" + date.getUTCSeconds()).slice(-2);
      },
      _formatPercentage: function(floatValue) {
        return (floatValue * 100).toFixed(2) + " %";
      },
      _renderExtendedProgress: function(data) {
        return this._formatBitrate(data.bitrate) + " | " + this._formatTime((data.total - data.loaded) * 8 / data.bitrate) + " | " + this._formatPercentage(data.loaded / data.total) + " | " + this._formatFileSize(data.loaded) + " / " + this._formatFileSize(data.total);
      },
      _hasError: function(file) {
        if (file.error) {
          return file.error;
        }
        if (this.options.maxNumberOfFiles < 0) {
          return "Maximum number of files exceeded";
        }
        if (!(this.options.acceptFileTypes.test(file.type) || this.options.acceptFileTypes.test(file.name))) {
          return "Filetype not allowed";
        }
        if (this.options.maxFileSize && file.size > this.options.maxFileSize) {
          return "File is too big";
        }
        if (typeof file.size === "number" && file.size < this.options.minFileSize) {
          return "File is too small";
        }
        return null;
      },
      _validate: function(files) {
        var that, valid;

        that = this;
        valid = !!files.length;
        $.each(files, function(index, file) {
          file.error = that._hasError(file);
          if (file.error) {
            return valid = false;
          }
        });
        return valid;
      },
      _renderTemplate: function(func, files) {
        var result;

        if (!func) {
          return $();
        }
        result = func({
          files: files,
          formatFileSize: this._formatFileSize,
          options: this.options,
          i18nCommon: i18nCommon
        });
        if (result instanceof $) {
          return result;
        }
        return $(this.options.templatesContainer).html(result).children();
      },
      _renderPreview: function(file, node) {
        var dfd, options, that;

        that = this;
        options = this.options;
        dfd = $.Deferred();
        return ((loadImage && loadImage(file, function(img) {
          img.className = 'profile-picture span4 offset1';
          node.append(img);
          if (options.nameContainer) {
            options.nameContainer.html(file.name);
          }
          that._forceReflow(node);
          that._transition(node).done(function() {
            return dfd.resolveWith(node);
          });
          if (!$.contains(that.document[0].body, node[0])) {
            return dfd.resolveWith(node);
          }
        }, {
          maxWidth: options.previewMaxWidth,
          maxHeight: options.previewMaxHeight,
          canvas: options.previewAsCanvas
        })) || dfd.resolveWith(node)) && dfd;
      },
      _renderPreviews: function(data) {
        var element, file, options, that;

        that = this;
        options = this.options;
        element = data.context;
        file = data.files[0];
        if (options.previewSourceFileTypes.test(file.type) && ($.type(options.previewSourceMaxFileSize) !== "number" || file.size < options.previewSourceMaxFileSize)) {
          that._processingQueue = that._processingQueue.pipe(function() {
            var dfd, ev;

            dfd = $.Deferred();
            ev = $.Event("previewdone", {
              target: element
            });
            that._renderPreview(file, element).done(function() {
              that._trigger(ev.type, ev, data);
              return dfd.resolveWith(that);
            });
            return dfd.promise();
          });
        }
        return this._processingQueue;
      },
      _renderUpload: function(files) {
        return $('#preview-profile-picture').html('');
      },
      _renderDownload: function(files) {
        return this._renderTemplate(this.options.downloadTemplate, files).find("a[download]").each(this._enableDragToDesktop).end();
      },
      _startHandler: function(e) {
        var button, data, template;

        e.preventDefault();
        button = $(e.currentTarget);
        template = $('#preview-profile-picture');
        data = template.data("data");
        if (data && data.submit && !data.jqXHR && data.submit()) {
          return button.prop("disabled", true);
        }
      },
      _cancelHandler: function(e) {
        var data, template;

        e.preventDefault();
        template = $(e.currentTarget).closest(".template-upload");
        data = template.data("data") || {};
        if (!data.jqXHR) {
          data.errorThrown = "abort";
          return this._trigger("fail", e, data);
        } else {
          return data.jqXHR.abort();
        }
      },
      _deleteHandler: function(e) {
        var button;

        e.preventDefault();
        button = $(e.currentTarget);
        return this._trigger("destroy", e, $.extend({
          context: button.closest(".template-download"),
          type: "DELETE",
          dataType: this.options.dataType
        }, button.data()));
      },
      _forceReflow: function(node) {
        return $.support.transition && node.length && node[0].offsetWidth;
      },
      _transition: function(node) {
        var dfd;

        dfd = $.Deferred();
        if ($.support.transition && node.hasClass("fade")) {
          node.bind($.support.transition.end, function(e) {
            if (e.target === node[0]) {
              node.unbind($.support.transition.end);
              return dfd.resolveWith(node);
            }
          }).toggleClass("in");
        } else {
          node.toggleClass("in");
          dfd.resolveWith(node);
        }
        return dfd;
      },
      _initButtonBarEventHandlers: function() {
        var fileUploadButtonBar, filesList;

        fileUploadButtonBar = this.element.find(".fileupload-buttonbar");
        filesList = this.options.filesContainer;
        this._on(fileUploadButtonBar.find(".start"), {
          click: function(e) {
            e.preventDefault();
            return filesList.find(".start").click();
          }
        });
        this._on(fileUploadButtonBar.find(".cancel"), {
          click: function(e) {
            e.preventDefault();
            return filesList.find(".cancel").click();
          }
        });
        this._on(fileUploadButtonBar.find(".delete"), {
          click: function(e) {
            e.preventDefault();
            filesList.find(".delete input:checked").siblings("button").click();
            return fileUploadButtonBar.find(".toggle").prop("checked", false);
          }
        });
        return this._on(fileUploadButtonBar.find(".toggle"), {
          change: function(e) {
            return filesList.find(".delete input").prop("checked", $(e.currentTarget).is(":checked"));
          }
        });
      },
      _destroyButtonBarEventHandlers: function() {
        this._off(this.element.find(".fileupload-buttonbar button"), "click");
        return this._off(this.element.find(".fileupload-buttonbar .toggle"), "change.");
      },
      _initEventHandlers: function() {
        this._super();
        return this._on(this.element, {
          "click .start": this._startHandler,
          "click .cancel": this._cancelHandler
        });
      },
      _destroyEventHandlers: function() {
        this._destroyButtonBarEventHandlers();
        this._off(this.options.filesContainer, "click");
        return this._super();
      },
      _enableFileInputButton: function() {
        return this.element.find(".fileinput-button input").prop("disabled", false).parent().removeClass("disabled");
      },
      _disableFileInputButton: function() {
        return this.element.find(".fileinput-button input").prop("disabled", true).parent().addClass("disabled");
      },
      _initTemplates: function() {
        var options;

        options = this.options;
        options.templatesContainer = this.document[0].createElement(options.filesContainer.prop("nodeName"));
        options.uploadTemplate = JST["src/js/templates/photo/pending.jst"];
        return options.downloadTemplate = JST["src/js/templates/file/download.jst"];
      },
      _initFilesContainer: function() {
        var options;

        options = this.options;
        if (options.filesContainer === undefined) {
          return options.filesContainer = this.element.find(".files");
        } else {
          if (!(options.filesContainer instanceof $)) {
            return options.filesContainer = $(options.filesContainer);
          }
        }
      },
      _stringToRegExp: function(str) {
        var modifiers, parts;

        parts = str.split("/");
        modifiers = parts.pop();
        parts.shift();
        return new RegExp(parts.join("/"), modifiers);
      },
      _initRegExpOptions: function() {
        var options;

        options = this.options;
        if ($.type(options.acceptFileTypes) === "string") {
          options.acceptFileTypes = this._stringToRegExp(options.acceptFileTypes);
        }
        if ($.type(options.previewSourceFileTypes) === "string") {
          return options.previewSourceFileTypes = this._stringToRegExp(options.previewSourceFileTypes);
        }
      },
      _initSpecialOptions: function() {
        this._super();
        this._initFilesContainer();
        this._initTemplates();
        return this._initRegExpOptions();
      },
      _setOption: function(key, value) {
        this._super(key, value);
        if (key === "maxNumberOfFiles") {
          return this._adjustMaxNumberOfFiles(0);
        }
      },
      _create: function() {
        this._super();
        this._refreshOptionsList.push("filesContainer");
        if (!this._processingQueue) {
          this._processingQueue = $.Deferred().resolveWith(this).promise();
          this.process = function() {
            return this._processingQueue;
          };
        }
        return this._resetFinishedDeferreds();
      },
      enable: function() {
        var wasDisabled;

        wasDisabled = false;
        if (this.options.disabled) {
          wasDisabled = true;
        }
        this._super();
        if (wasDisabled) {
          this.element.find("input, button").prop("disabled", false);
          return this._enableFileInputButton();
        }
      },
      disable: function() {
        if (!this.options.disabled) {
          this.element.find("input, button").prop("disabled", true);
          this._disableFileInputButton();
        }
        return this._super();
      }
    });
  });

}).call(this);
