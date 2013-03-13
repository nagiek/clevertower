(function() {

  (function(factory) {
    "use strict";
    if (typeof define === "function" && define.amd) {
      return define(["jquery", "jqueryui"], factory);
    } else {
      return factory(window.jQuery);
    }
  })(function($) {
    "use strict";
    $.support.xhrFileUpload = !!(window.XMLHttpRequestUpload && window.FileReader);
    $.support.xhrFormDataFileUpload = !!window.FormData;
    $.propHooks.elements = {
      get: function(form) {
        if ($.nodeName(form, "form")) {
          return $.grep(form.elements, function(elem) {
            return !$.nodeName(elem, "input") || elem.type !== "file";
          });
        }
        return null;
      }
    };
    return $.widget("blueimp.fileupload", {
      options: {
        dropZone: $(document),
        pasteZone: $(document),
        fileInput: undefined,
        replaceFileInput: true,
        paramName: undefined,
        singleFileUploads: true,
        limitMultiFileUploads: undefined,
        sequentialUploads: false,
        limitConcurrentUploads: undefined,
        forceIframeTransport: false,
        redirect: undefined,
        redirectParamName: undefined,
        postMessage: undefined,
        multipart: true,
        maxChunkSize: undefined,
        uploadedBytes: undefined,
        recalculateProgress: true,
        progressInterval: 100,
        bitrateInterval: 500,
        formData: function(form) {
          return form.serializeArray();
        },
        add: function(e, data) {
          return data.submit();
        },
        processData: false,
        contentType: false,
        cache: false
      },
      _refreshOptionsList: ["fileInput", "dropZone", "pasteZone", "multipart", "forceIframeTransport"],
      _BitrateTimer: function() {
        this.timestamp = +(new Date());
        this.loaded = 0;
        this.bitrate = 0;
        return this.getBitrate = function(now, loaded, interval) {
          var timeDiff;
          timeDiff = now - this.timestamp;
          if (!this.bitrate || !interval || timeDiff > interval) {
            this.bitrate = (loaded - this.loaded) * (1000 / timeDiff) * 8;
            this.loaded = loaded;
            this.timestamp = now;
          }
          return this.bitrate;
        };
      },
      _isXHRUpload: function(options) {
        return !options.forceIframeTransport && ((!options.multipart && $.support.xhrFileUpload) || $.support.xhrFormDataFileUpload);
      },
      _getFormData: function(options) {
        var formData;
        formData = void 0;
        if (typeof options.formData === "function") {
          return options.formData(options.form);
        }
        if ($.isArray(options.formData)) {
          return options.formData;
        }
        if (options.formData) {
          formData = [];
          $.each(options.formData, function(name, value) {
            return formData.push({
              name: name,
              value: value
            });
          });
          return formData;
        }
        return [];
      },
      _getTotal: function(files) {
        var total;
        total = 0;
        $.each(files, function(index, file) {
          return total += file.size || 1;
        });
        return total;
      },
      _onProgress: function(e, data) {
        var loaded, now, total;
        if (e.lengthComputable) {
          now = +(new Date());
          total = void 0;
          loaded = void 0;
          if (data._time && data.progressInterval && (now - data._time < data.progressInterval) && e.loaded !== e.total) {
            return;
          }
          data._time = now;
          total = data.total || this._getTotal(data.files);
          loaded = parseInt(e.loaded / e.total * (data.chunkSize || total), 10) + (data.uploadedBytes || 0);
          this._loaded += loaded - (data.loaded || data.uploadedBytes || 0);
          data.lengthComputable = true;
          data.loaded = loaded;
          data.total = total;
          data.bitrate = data._bitrateTimer.getBitrate(now, loaded, data.bitrateInterval);
          this._trigger("progress", e, data);
          return this._trigger("progressall", e, {
            lengthComputable: true,
            loaded: this._loaded,
            total: this._total,
            bitrate: this._bitrateTimer.getBitrate(now, this._loaded, data.bitrateInterval)
          });
        }
      },
      _initProgressListener: function(options) {
        var that, xhr;
        that = this;
        xhr = (options.xhr ? options.xhr() : $.ajaxSettings.xhr());
        if (xhr.upload) {
          $(xhr.upload).bind("progress", function(e) {
            var oe;
            oe = e.originalEvent;
            e.lengthComputable = oe.lengthComputable;
            e.loaded = oe.loaded;
            e.total = oe.total;
            return that._onProgress(e, options);
          });
          return options.xhr = function() {
            return xhr;
          };
        }
      },
      _initXHRData: function(options) {
        var file, formData, multipart, paramName;
        formData = void 0;
        file = options.files[0];
        multipart = options.multipart || !$.support.xhrFileUpload;
        paramName = options.paramName[0];
        options.headers = options.headers || {};
        if (options.contentRange) {
          options.headers["Content-Range"] = options.contentRange;
        }
        if (!multipart) {
          options.headers["Content-Disposition"] = "attachment; filename=\"" + encodeURI(file.name) + "\"";
          options.contentType = file.type;
          options.data = options.blob || file;
        } else if ($.support.xhrFormDataFileUpload) {
          if (options.postMessage) {
            formData = this._getFormData(options);
            if (options.blob) {
              formData.push({
                name: paramName,
                value: options.blob
              });
            } else {
              $.each(options.files, function(index, file) {
                return formData.push({
                  name: options.paramName[index] || paramName,
                  value: file
                });
              });
            }
          } else {
            if (options.formData instanceof FormData) {
              formData = options.formData;
            } else {
              formData = new FormData();
              $.each(this._getFormData(options), function(index, field) {
                return formData.append(field.name, field.value);
              });
            }
            if (options.blob) {
              options.headers["Content-Disposition"] = "attachment; filename=\"" + encodeURI(file.name) + "\"";
              formData.append(paramName, options.blob, file.name);
            } else {
              $.each(options.files, function(index, file) {
                if ((window.Blob && file instanceof Blob) || (window.File && file instanceof File)) {
                  return formData.append(options.paramName[index] || paramName, file, file.name);
                }
              });
            }
          }
          options.data = formData;
        }
        return options.blob = null;
      },
      _initIframeSettings: function(options) {
        options.dataType = "iframe " + (options.dataType || "");
        options.formData = this._getFormData(options);
        if (options.redirect && $("<a></a>").prop("href", options.url).prop("host") !== location.host) {
          return options.formData.push({
            name: options.redirectParamName || "redirect",
            value: options.redirect
          });
        }
      },
      _initDataSettings: function(options) {
        if (this._isXHRUpload(options)) {
          if (!this._chunkedUpload(options, true)) {
            if (!options.data) {
              this._initXHRData(options);
            }
            this._initProgressListener(options);
          }
          if (options.postMessage) {
            return options.dataType = "postmessage " + (options.dataType || "");
          }
        } else {
          return this._initIframeSettings(options, "iframe");
        }
      },
      _getParamName: function(options) {
        var fileInput, paramName;
        fileInput = $(options.fileInput);
        paramName = options.paramName;
        if (!paramName) {
          paramName = [];
          fileInput.each(function() {
            var i, input, name, _results;
            input = $(this);
            name = input.prop("name") || "files[]";
            i = (input.prop("files") || [1]).length;
            _results = [];
            while (i) {
              paramName.push(name);
              _results.push(i -= 1);
            }
            return _results;
          });
          if (!paramName.length) {
            paramName = [fileInput.prop("name") || "files[]"];
          }
        } else {
          if (!$.isArray(paramName)) {
            paramName = [paramName];
          }
        }
        return paramName;
      },
      _initFormSettings: function(options) {
        if (!options.form || !options.form.length) {
          options.form = $(options.fileInput.prop("form"));
          if (!options.form.length) {
            options.form = $(this.options.fileInput.prop("form"));
          }
        }
        options.paramName = this._getParamName(options);
        if (!options.url) {
          options.url = options.form.prop("action") || location.href;
        }
        options.type = (options.type || options.form.prop("method") || "").toUpperCase();
        if (options.type !== "POST" && options.type !== "PUT" && options.type !== "PATCH") {
          options.type = "POST";
        }
        if (!options.formAcceptCharset) {
          return options.formAcceptCharset = options.form.attr("accept-charset");
        }
      },
      _getAJAXSettings: function(data) {
        var options;
        options = $.extend({}, this.options, data);
        this._initFormSettings(options);
        this._initDataSettings(options);
        return options;
      },
      _enhancePromise: function(promise) {
        promise.success = promise.done;
        promise.error = promise.fail;
        promise.complete = promise.always;
        return promise;
      },
      _getXHRPromise: function(resolveOrReject, context, args) {
        var dfd, promise;
        dfd = $.Deferred();
        promise = dfd.promise();
        context = context || this.options.context || promise;
        if (resolveOrReject === true) {
          dfd.resolveWith(context, args);
        } else {
          if (resolveOrReject === false) {
            dfd.rejectWith(context, args);
          }
        }
        promise.abort = dfd.promise;
        return this._enhancePromise(promise);
      },
      _getUploadedBytes: function(jqXHR) {
        var parts, range, upperBytesPos;
        range = jqXHR.getResponseHeader("Range");
        parts = range && range.split("-");
        upperBytesPos = parts && parts.length > 1 && parseInt(parts[1], 10);
        return upperBytesPos && upperBytesPos + 1;
      },
      _chunkedUpload: function(options, testOnly) {
        var dfd, file, fs, jqXHR, mcs, promise, slice, that, ub, upload;
        that = this;
        file = options.files[0];
        fs = file.size;
        ub = options.uploadedBytes = options.uploadedBytes || 0;
        mcs = options.maxChunkSize || fs;
        slice = file.slice || file.webkitSlice || file.mozSlice;
        dfd = $.Deferred();
        promise = dfd.promise();
        jqXHR = void 0;
        upload = void 0;
        if (!(this._isXHRUpload(options) && slice && (ub || mcs < fs)) || options.data) {
          return false;
        }
        if (testOnly) {
          return true;
        }
        if (ub >= fs) {
          file.error = "Uploaded bytes exceed file size";
          return this._getXHRPromise(false, options.context, [null, "error", file.error]);
        }
        upload = function() {
          var o;
          o = $.extend({}, options);
          o.blob = slice.call(file, ub, ub + mcs, file.type);
          o.chunkSize = o.blob.size;
          o.contentRange = "bytes " + ub + "-" + (ub + o.chunkSize - 1) + "/" + fs;
          that._initXHRData(o);
          that._initProgressListener(o);
          return jqXHR = ((that._trigger("chunksend", null, o) !== false && $.ajax(o)) || that._getXHRPromise(false, o.context)).done(function(result, textStatus, jqXHR) {
            ub = that._getUploadedBytes(jqXHR) || (ub + o.chunkSize);
            if (!o.loaded || o.loaded < o.total) {
              that._onProgress($.Event("progress", {
                lengthComputable: true,
                loaded: ub - o.uploadedBytes,
                total: ub - o.uploadedBytes
              }), o);
            }
            options.uploadedBytes = o.uploadedBytes = ub;
            o.result = result;
            o.textStatus = textStatus;
            o.jqXHR = jqXHR;
            that._trigger("chunkdone", null, o);
            that._trigger("chunkalways", null, o);
            if (ub < fs) {
              return upload();
            } else {
              return dfd.resolveWith(o.context, [result, textStatus, jqXHR]);
            }
          }).fail(function(jqXHR, textStatus, errorThrown) {
            o.jqXHR = jqXHR;
            o.textStatus = textStatus;
            o.errorThrown = errorThrown;
            that._trigger("chunkfail", null, o);
            that._trigger("chunkalways", null, o);
            return dfd.rejectWith(o.context, [jqXHR, textStatus, errorThrown]);
          });
        };
        this._enhancePromise(promise);
        promise.abort = function() {
          return jqXHR.abort();
        };
        upload();
        return promise;
      },
      _beforeSend: function(e, data) {
        if (this._active === 0) {
          this._trigger("start");
          this._bitrateTimer = new this._BitrateTimer();
        }
        this._active += 1;
        this._loaded += data.uploadedBytes || 0;
        return this._total += this._getTotal(data.files);
      },
      _onDone: function(result, textStatus, jqXHR, options) {
        var total;
        if (!this._isXHRUpload(options) || !options.loaded || options.loaded < options.total) {
          total = this._getTotal(options.files) || 1;
          this._onProgress($.Event("progress", {
            lengthComputable: true,
            loaded: total,
            total: total
          }), options);
        }
        options.result = result;
        options.textStatus = textStatus;
        options.jqXHR = jqXHR;
        return this._trigger("done", null, options);
      },
      _onFail: function(jqXHR, textStatus, errorThrown, options) {
        options.jqXHR = jqXHR;
        options.textStatus = textStatus;
        options.errorThrown = errorThrown;
        this._trigger("fail", null, options);
        if (options.recalculateProgress) {
          this._loaded -= options.loaded || options.uploadedBytes || 0;
          return this._total -= options.total || this._getTotal(options.files);
        }
      },
      _onAlways: function(jqXHRorResult, textStatus, jqXHRorError, options) {
        this._active -= 1;
        this._trigger("always", null, options);
        if (this._active === 0) {
          this._trigger("stop");
          this._loaded = this._total = 0;
          return this._bitrateTimer = null;
        }
      },
      _onSend: function(e, data) {
        var aborted, jqXHR, options, pipe, send, slot, that;
        that = this;
        jqXHR = void 0;
        aborted = void 0;
        slot = void 0;
        pipe = void 0;
        options = that._getAJAXSettings(data);
        send = function() {
          that._sending += 1;
          options._bitrateTimer = new that._BitrateTimer();
          jqXHR = jqXHR || (((aborted || that._trigger("send", e, options) === false) && that._getXHRPromise(false, options.context, aborted)) || that._chunkedUpload(options) || $.ajax(options)).done(function(result, textStatus, jqXHR) {
            return that._onDone(result, textStatus, jqXHR, options);
          }).fail(function(jqXHR, textStatus, errorThrown) {
            return that._onFail(jqXHR, textStatus, errorThrown, options);
          }).always(function(jqXHRorResult, textStatus, jqXHRorError) {
            var isPending, nextSlot, _results;
            that._sending -= 1;
            that._onAlways(jqXHRorResult, textStatus, jqXHRorError, options);
            if (options.limitConcurrentUploads && options.limitConcurrentUploads > that._sending) {
              nextSlot = that._slots.shift();
              isPending = void 0;
              _results = [];
              while (nextSlot) {
                isPending = (nextSlot.state ? nextSlot.state() === "pending" : !nextSlot.isRejected());
                if (isPending) {
                  nextSlot.resolve();
                  break;
                }
                _results.push(nextSlot = that._slots.shift());
              }
              return _results;
            }
          });
          return jqXHR;
        };
        this._beforeSend(e, options);
        if (this.options.sequentialUploads || (this.options.limitConcurrentUploads && this.options.limitConcurrentUploads <= this._sending)) {
          if (this.options.limitConcurrentUploads > 1) {
            slot = $.Deferred();
            this._slots.push(slot);
            pipe = slot.pipe(send);
          } else {
            pipe = (this._sequence = this._sequence.pipe(send, send));
          }
          pipe.abort = function() {
            aborted = [undefined, "abort", "abort"];
            if (!jqXHR) {
              if (slot) {
                slot.rejectWith(options.context, aborted);
              }
              return send();
            }
            return jqXHR.abort();
          };
          return this._enhancePromise(pipe);
        }
        return send();
      },
      _onAdd: function(e, data) {
        var fileSet, i, limit, options, paramName, paramNameSet, paramNameSlice, result, that;
        that = this;
        result = true;
        options = $.extend({}, this.options, data);
        limit = options.limitMultiFileUploads;
        paramName = this._getParamName(options);
        paramNameSet = void 0;
        paramNameSlice = void 0;
        fileSet = void 0;
        i = void 0;
        if (!(options.singleFileUploads || limit) || !this._isXHRUpload(options)) {
          fileSet = [data.files];
          paramNameSet = [paramName];
        } else if (!options.singleFileUploads && limit) {
          fileSet = [];
          paramNameSet = [];
          i = 0;
          while (i < data.files.length) {
            fileSet.push(data.files.slice(i, i + limit));
            paramNameSlice = paramName.slice(i, i + limit);
            if (!paramNameSlice.length) {
              paramNameSlice = paramName;
            }
            paramNameSet.push(paramNameSlice);
            i += limit;
          }
        } else {
          paramNameSet = paramName;
        }
        data.originalFiles = data.files;
        $.each(fileSet || data.files, function(index, element) {
          var newData;
          newData = $.extend({}, data);
          newData.files = (fileSet ? element : [element]);
          newData.paramName = paramNameSet[index];
          newData.submit = function() {
            newData.jqXHR = this.jqXHR = (that._trigger("submit", e, this) !== false) && that._onSend(e, this);
            return this.jqXHR;
          };
          result = that._trigger("add", e, newData);
          return result;
        });
        return result;
      },
      _replaceFileInput: function(input) {
        var inputClone;
        inputClone = input.clone(true);
        $("<form></form>").append(inputClone)[0].reset();
        input.after(inputClone).detach();
        $.cleanData(input.unbind("remove"));
        this.options.fileInput = this.options.fileInput.map(function(i, el) {
          if (el === input[0]) {
            return inputClone[0];
          }
          return el;
        });
        if (input[0] === this.element[0]) {
          return this.element = inputClone;
        }
      },
      _handleFileTreeEntry: function(entry, path) {
        var dfd, dirReader, errorHandler, that;
        that = this;
        dfd = $.Deferred();
        errorHandler = function(e) {
          if (e && !e.entry) {
            e.entry = entry;
          }
          return dfd.resolve([e]);
        };
        dirReader = void 0;
        path = path || "";
        if (entry.isFile) {
          if (entry._file) {
            entry._file.relativePath = path;
            dfd.resolve(entry._file);
          } else {
            entry.file((function(file) {
              file.relativePath = path;
              return dfd.resolve(file);
            }), errorHandler);
          }
        } else if (entry.isDirectory) {
          dirReader = entry.createReader();
          dirReader.readEntries((function(entries) {
            return that._handleFileTreeEntries(entries, path + entry.name + "/").done(function(files) {
              return dfd.resolve(files);
            }).fail(errorHandler);
          }), errorHandler);
        } else {
          dfd.resolve([]);
        }
        return dfd.promise();
      },
      _handleFileTreeEntries: function(entries, path) {
        var that;
        that = this;
        return $.when.apply($, $.map(entries, function(entry) {
          return that._handleFileTreeEntry(entry, path);
        })).pipe(function() {
          return Array.prototype.concat.apply([], arguments_);
        });
      },
      _getDroppedFiles: function(dataTransfer) {
        var items;
        dataTransfer = dataTransfer || {};
        items = dataTransfer.items;
        if (items && items.length && (items[0].webkitGetAsEntry || items[0].getAsEntry)) {
          return this._handleFileTreeEntries($.map(items, function(item) {
            var entry;
            entry = void 0;
            if (item.webkitGetAsEntry) {
              entry = item.webkitGetAsEntry();
              if (entry) {
                entry._file = item.getAsFile();
              }
              return entry;
            }
            return item.getAsEntry();
          }));
        }
        return $.Deferred().resolve($.makeArray(dataTransfer.files)).promise();
      },
      _getSingleFileInputFiles: function(fileInput) {
        var entries, files, value;
        fileInput = $(fileInput);
        entries = fileInput.prop("webkitEntries") || fileInput.prop("entries");
        files = void 0;
        value = void 0;
        if (entries && entries.length) {
          return this._handleFileTreeEntries(entries);
        }
        files = $.makeArray(fileInput.prop("files"));
        if (!files.length) {
          value = fileInput.prop("value");
          if (!value) {
            return $.Deferred().resolve([]).promise();
          }
          files = [
            {
              name: value.replace(/^.*\\/, "")
            }
          ];
        } else if (files[0].name === undefined && files[0].fileName) {
          $.each(files, function(index, file) {
            file.name = file.fileName;
            return file.size = file.fileSize;
          });
        }
        return $.Deferred().resolve(files).promise();
      },
      _getFileInputFiles: function(fileInput) {
        if ((!(fileInput instanceof $)) || fileInput.length === 1) {
          return this._getSingleFileInputFiles(fileInput);
        }
        return $.when.apply($, $.map(fileInput, this._getSingleFileInputFiles)).pipe(function() {
          return Array.prototype.concat.apply([], arguments_);
        });
      },
      _onChange: function(e) {
        var data, that;
        that = this;
        data = {
          fileInput: $(e.target),
          form: $(e.target.form)
        };
        return this._getFileInputFiles(data.fileInput).always(function(files) {
          data.files = files;
          if (that.options.replaceFileInput) {
            that._replaceFileInput(data.fileInput);
          }
          if (that._trigger("change", e, data) !== false) {
            return that._onAdd(e, data);
          }
        });
      },
      _onPaste: function(e) {
        var cbd, data, items;
        cbd = e.originalEvent.clipboardData;
        items = (cbd && cbd.items) || [];
        data = {
          files: []
        };
        $.each(items, function(index, item) {
          var file;
          file = item.getAsFile && item.getAsFile();
          if (file) {
            return data.files.push(file);
          }
        });
        if (this._trigger("paste", e, data) === false || this._onAdd(e, data) === false) {
          return false;
        }
      },
      _onDrop: function(e) {
        var data, dataTransfer, that;
        that = this;
        dataTransfer = e.dataTransfer = e.originalEvent.dataTransfer;
        data = {};
        if (dataTransfer && dataTransfer.files && dataTransfer.files.length) {
          e.preventDefault();
        }
        return this._getDroppedFiles(dataTransfer).always(function(files) {
          data.files = files;
          if (that._trigger("drop", e, data) !== false) {
            return that._onAdd(e, data);
          }
        });
      },
      _onDragOver: function(e) {
        var dataTransfer;
        dataTransfer = e.dataTransfer = e.originalEvent.dataTransfer;
        if (this._trigger("dragover", e) === false) {
          return false;
        }
        if (dataTransfer && $.inArray("Files", dataTransfer.types) !== -1) {
          dataTransfer.dropEffect = "copy";
          return e.preventDefault();
        }
      },
      _initEventHandlers: function() {
        if (this._isXHRUpload(this.options)) {
          this._on(this.options.dropZone, {
            dragover: this._onDragOver,
            drop: this._onDrop
          });
          this._on(this.options.pasteZone, {
            paste: this._onPaste
          });
        }
        return this._on(this.options.fileInput, {
          change: this._onChange
        });
      },
      _destroyEventHandlers: function() {
        this._off(this.options.dropZone, "dragover drop");
        this._off(this.options.pasteZone, "paste");
        return this._off(this.options.fileInput, "change");
      },
      _setOption: function(key, value) {
        var refresh;
        refresh = $.inArray(key, this._refreshOptionsList) !== -1;
        if (refresh) {
          this._destroyEventHandlers();
        }
        this._super(key, value);
        if (refresh) {
          this._initSpecialOptions();
          return this._initEventHandlers();
        }
      },
      _initSpecialOptions: function() {
        var options;
        options = this.options;
        if (options.fileInput === undefined) {
          options.fileInput = (this.element.is("input[type=\"file\"]") ? this.element : this.element.find("input[type=\"file\"]"));
        } else {
          if (!(options.fileInput instanceof $)) {
            options.fileInput = $(options.fileInput);
          }
        }
        if (!(options.dropZone instanceof $)) {
          options.dropZone = $(options.dropZone);
        }
        if (!(options.pasteZone instanceof $)) {
          return options.pasteZone = $(options.pasteZone);
        }
      },
      _create: function() {
        var options;
        options = this.options;
        $.extend(options, $(this.element[0].cloneNode(false)).data());
        this._initSpecialOptions();
        this._slots = [];
        this._sequence = this._getXHRPromise(true);
        this._sending = this._active = this._loaded = this._total = 0;
        return this._initEventHandlers();
      },
      _destroy: function() {
        return this._destroyEventHandlers();
      },
      add: function(data) {
        var that;
        that = this;
        if (!data || this.options.disabled) {
          return;
        }
        if (data.fileInput && !data.files) {
          return this._getFileInputFiles(data.fileInput).always(function(files) {
            data.files = files;
            return that._onAdd(null, data);
          });
        } else {
          data.files = $.makeArray(data.files);
          return this._onAdd(null, data);
        }
      },
      send: function(data) {
        var aborted, dfd, jqXHR, promise, that;
        if (data && !this.options.disabled) {
          if (data.fileInput && !data.files) {
            that = this;
            dfd = $.Deferred();
            promise = dfd.promise();
            jqXHR = void 0;
            aborted = void 0;
            promise.abort = function() {
              aborted = true;
              if (jqXHR) {
                return jqXHR.abort();
              }
              dfd.reject(null, "abort", "abort");
              return promise;
            };
            this._getFileInputFiles(data.fileInput).always(function(files) {
              if (aborted) {
                return;
              }
              data.files = files;
              return jqXHR = that._onSend(null, data).then(function(result, textStatus, jqXHR) {
                return dfd.resolve(result, textStatus, jqXHR);
              }, function(jqXHR, textStatus, errorThrown) {
                return dfd.reject(jqXHR, textStatus, errorThrown);
              });
            });
            return this._enhancePromise(promise);
          }
          data.files = $.makeArray(data.files);
          if (data.files.length) {
            return this._onSend(null, data);
          }
        }
        return this._getXHRPromise(false, data && data.context);
      }
    });
  });

}).call(this);
