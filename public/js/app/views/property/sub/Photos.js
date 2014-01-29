(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "models/Photo", "models/Activity", "collections/PhotoList", "views/photo/Show", "i18n!nls/property", "i18n!nls/common", "canvas-to-blob", "templates/property/sub/photos", 'jqueryuiwidget', 'jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-ui'], function($, _, Parse, Property, Photo, Activity, PhotoList, PhotoView, i18nProperty, i18nCommon, canvas) {
    var PropertyPhotosView, _ref;

    return PropertyPhotosView = (function(_super) {
      __extends(PropertyPhotosView, _super);

      function PropertyPhotosView() {
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        this.clear = __bind(this.clear, this);        _ref = PropertyPhotosView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyPhotosView.prototype.el = ".content";

      PropertyPhotosView.prototype.initialize = function() {
        this.on("view:change", this.clear);
        this.unUploadedPhotos = 0;
        this.model.prep("photos");
        this.listenTo(this.model.photos, "add", this.addOne);
        return this.listenTo(this.model.photos, "reset", this.addAll);
      };

      PropertyPhotosView.prototype.render = function() {
        var uploads,
          _this = this;

        _this = this;
        this.$el.html(JST["src/js/templates/property/sub/photos.jst"]({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        }));
        this.$list = $("#photo-list");
        this.$fileForm = $("#fileupload");
        uploads = [];
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
            _this.$('.empty').remove();
            return delete data.headers['Content-Disposition'];
          },
          done: function(e, data) {
            var file, photo, that;

            file = data.result;
            photo = new Photo({
              network: _this.model.get("network"),
              property: _this.model,
              url: file.url,
              name: file.name
            });
            that = $(this).data("blueimp-fileupload") || $(this).data("fileupload");
            that._transition(data.context);
            data.context.each(function(index) {
              var node;

              node = $(this);
              return that._transition(node).done(function() {
                return node.remove();
              });
            });
            return uploads.push(photo.save());
          },
          stop: function(e, data) {
            Parse.Promise.when(uploads).then(function() {
              var activity, photo, _i, _len;

              for (_i = 0, _len = arguments.length; _i < _len; _i++) {
                photo = arguments[_i];
                _this.model.photos.add(photo);
              }
              activity = new Activity({
                image: arguments[0].get("url"),
                title: i18nProperty.activity.added_photos(arguments.length),
                "public": true,
                center: _this.model.get("center"),
                property: _this.model,
                network: _this.model.get("network"),
                subject: _this.model.get("profile"),
                object: _this.model.get("location") ? _this.model.get("location").get("profile") : void 0,
                locality: _this.model.get("locality"),
                administrative_area_level_1: _this.model.get("administrative_area_level_1"),
                administrative_area_level_2: _this.model.get("administrative_area_level_2"),
                location: _this.model.get("location"),
                neighbourhood: _this.model.get("neighbourhood"),
                country: _this.model.get("country"),
                postal_code: _this.model.get("postal_code")
              });
              activity.save().then(function() {
                if (Parse.App.activity) {
                  return Parse.App.activity.add(activity);
                }
              }, function(error) {
                return console.log(error);
              });
              return uploads = [];
            });
            return _this.$(".fileupload-progress").addClass("hide");
          }
        });
        if (this.model.photos.length === 0) {
          this.model.photos.fetch();
        } else {
          this.addAll();
        }
        return this;
      };

      PropertyPhotosView.prototype.clear = function(e) {
        this.undelegateEvents();
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
        if (this.model.photos.length !== 0) {
          return this.model.photos.each(this.addOne);
        } else {
          return this.$list.before('<p class="empty">' + i18nProperty.empty.photos + '</p>');
        }
      };

      return PropertyPhotosView;

    })(Parse.View);
  });

}).call(this);
