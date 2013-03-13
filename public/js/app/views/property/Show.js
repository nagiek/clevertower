(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", 'templates/property/show', "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/other", "templates/property/menu/actions"], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var PropertyView;
    return PropertyView = (function(_super) {

      __extends(PropertyView, _super);

      function PropertyView() {
        return PropertyView.__super__.constructor.apply(this, arguments);
      }

      PropertyView.prototype.el = "#property";

      PropertyView.prototype.events = {
        'click #edit-profile-picture': 'editProfilePicture'
      };

      PropertyView.prototype.initialize = function(attrs) {
        var collections,
          _this = this;
        this.action = attrs.action;
        collections = {
          cover: this.model.cover('profile'),
          tasks: '0',
          incomes: '0',
          expenses: '0',
          vacant_units: '0',
          units: '0'
        };
        $(this.el).html(JST["src/js/templates/property/show.jst"](_.merge(this.model.toJSON(), collections, {
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        })));
        this.$form = $("#profile-picture-upload");
        this.model.on('change:image_profile', function(model, name) {
          return _this.refresh();
        });
        return this.render();
      };

      PropertyView.prototype.render = function() {
        var _this = this;
        require(["views/property/sub/" + this.action], function(PropertySubView) {
          var propertyView;
          return propertyView = new PropertySubView({
            model: _this.model
          });
        });
        return this;
      };

      PropertyView.prototype.refresh = function() {
        return $('#preview-profile-picture img').prop('src', this.model.cover('profile'));
      };

      PropertyView.prototype.editProfilePicture = function() {
        var _this = this;
        _this = this;
        return require(['jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-pr'], function() {
          _this.$form.fileupload({
            autoUpload: false,
            type: "POST",
            dataType: "json",
            nameContainer: $('#preview-profile-picture-name'),
            filesContainer: $('#preview-profile-picture'),
            multipart: false,
            context: _this.$form[0],
            submit: function(e, data) {
              return data.url = "https://api.parse.com/1/files/" + data.files[0].name;
            },
            beforeSend: function(event, files, index, xhr, handler, callBack) {
              event.setRequestHeader("X-Parse-Application-Id", "6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO");
              return event.setRequestHeader("X-Parse-REST-API-Key", "qgfCjwKVtDGiIKHxQmojnhoIsID7dcTHnYWZ0cf1");
            },
            send: function(e, data) {
              return delete data.headers['Content-Disposition'];
            },
            done: function(e, data) {
              var file;
              file = data.result;
              _this.model.save({
                image_thumb: file.url,
                image_profile: file.url,
                image_full: file.url
              });
              return $('#edit-profile-picture-modal').modal('hide');
            }
          });
          return $('#edit-profile-picture-modal').modal();
        });
      };

      return PropertyView;

    })(Parse.View);
  });

}).call(this);
