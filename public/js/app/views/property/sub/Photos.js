(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "models/Photo", "collections/PhotoList", "views/photo/Show", "i18n!nls/property", "i18n!nls/common", "templates/property/sub/photos", 'jqueryuiwidget', 'jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-ui'], function($, _, Parse, Property, Photo, PhotoList, PhotoView, i18nProperty, i18nCommon) {
    var PropertyPhotosView;
    return PropertyPhotosView = (function(_super) {

      __extends(PropertyPhotosView, _super);

      function PropertyPhotosView() {
        this.addAll = __bind(this.addAll, this);

        this.addOne = __bind(this.addOne, this);

        this.clear = __bind(this.clear, this);
        return PropertyPhotosView.__super__.constructor.apply(this, arguments);
      }

      PropertyPhotosView.prototype.el = ".content";

      PropertyPhotosView.prototype.initialize = function() {
        _.bindAll(this, 'save', 'render');
        this.on("view:change", this.clear);
        this.unUploadedPhotos = 0;
        this.photos = new PhotoList([], {
          property: this.model
        });
        this.photos.bind("add", this.addOne);
        return this.photos.bind("reset", this.addAll);
      };

      PropertyPhotosView.prototype.render = function() {
        var _this;
        _this = this;
        this.$el.html(JST["src/js/templates/property/sub/photos.jst"](_.merge({
          property: this.model,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        })));
        this.$list = $("#photo-list");
        this.$fileForm = $("#fileupload");
        this.$fileForm.fileupload({
          autoUpload: false,
          type: "POST",
          dataType: "json",
          filesContainer: '#non-uploaded-photo-list',
          multipart: false,
          context: this.$fileForm[0],
          process: [
            {
              action: 'load',
              fileTypes: /^photo\/(gif|jpe?g|png)$/,
              maxFileSize: 4000000
            }, {
              action: 'resize',
              maxWidth: 1920,
              maxHeight: 1200
            }, {
              action: 'save'
            }
          ],
          submit: function(e, data) {
            return data.url = "https://api.parse.com/1/files/" + data.files[0].name;
          },
          send: function(e, data) {
            return delete data.headers['Content-Disposition'];
          },
          done: function(e, data) {
            var file, that;
            that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
            that._transition(data.context);
            file = data.result;
            _this.photos.create({
              network: _this.model.get("network"),
              property: _this.model,
              url: file.url,
              name: file.name
            });
            $('.empty').remove();
            return data.context.each(function(index) {
              var node;
              node = $(this);
              return that._transition(node).done(function() {
                return node.remove();
              });
            });
          }
        });
        this.photos.fetch();
        return this;
      };

      PropertyPhotosView.prototype.clear = function(e) {
        this.undelegateEvents();
        delete this.photos;
        return delete this;
      };

      PropertyPhotosView.prototype.addOne = function(photo) {
        var view;
        view = new PhotoView({
          model: photo
        });
        return this.$list.append(view.render().el);
      };

      PropertyPhotosView.prototype.addAll = function(collection, filter) {
        this.$list.html("");
        if (this.photos.length !== 0) {
          return this.photos.each(this.addOne);
        } else {
          return this.$list.before('<p class="empty">' + i18nProperty.collection.empty.photos + '</p>');
        }
      };

      return PropertyPhotosView;

    })(Parse.View);
  });

}).call(this);
