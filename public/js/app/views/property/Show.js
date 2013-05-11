(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', 'models/Unit', 'models/Lease', 'models/Inquiry', "i18n!nls/property", "i18n!nls/common", "underscore.inflection", 'templates/property/show', "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/building", "templates/property/menu/actions"], function($, _, Parse, Property, Unit, Lease, Inquiry, i18nProperty, i18nCommon, inflection) {
    var ShowPropertyView;
    return ShowPropertyView = (function(_super) {

      __extends(ShowPropertyView, _super);

      function ShowPropertyView() {
        this.clear = __bind(this.clear, this);

        this.renderSubView = __bind(this.renderSubView, this);

        this.changeSubView = __bind(this.changeSubView, this);
        return ShowPropertyView.__super__.constructor.apply(this, arguments);
      }

      ShowPropertyView.prototype.el = '#property';

      ShowPropertyView.prototype.events = {
        'click .edit-profile-picture': 'editProfilePicture'
      };

      ShowPropertyView.prototype.initialize = function(attrs) {
        var _this = this;
        this.$form = $("#profile-picture-upload");
        this.model.prep('units');
        this.model.prep('leases');
        this.model.prep('listings');
        this.model.prep('inquiries');
        this.model.on('change:image_profile', function(model, name) {
          return _this.refresh;
        });
        this.model.on('destroy', this.clear);
        this.render();
        return this.changeSubView(attrs.path, attrs.params);
      };

      ShowPropertyView.prototype.render = function() {
        var vars;
        vars = _.merge(this.model.toJSON(), {
          publicUrl: this.model.publicUrl(),
          cover: this.model.cover('profile'),
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        });
        this.$el.html(JST["src/js/templates/property/show.jst"](vars));
        return this;
      };

      ShowPropertyView.prototype.changeSubView = function(path, params) {
        var action, name, node, nodeType, propertyCentric, subaction, subid, submodel,
          _this = this;
        action = path ? path.split("/") : Array('units');
        if (action.length === 1 || action[0] === "add") {
          name = "views/property/sub/" + (action.join("/"));
          return this.renderSubView(name, {
            model: this.model,
            params: params
          });
        } else {
          propertyCentric = false;
          node = action[0][0].toUpperCase() + inflection.singularize[action[0]].substring(1);
          subid = action[1];
          subaction = action[2] ? action[2] : "show";
          name = "views/" + node + "/" + subaction;
          submodel = this.model[action[0]] ? this.model[action[0]].get(subid) : false;
          if (submodel) {
            return this.renderSubView(name, {
              property: this.model,
              model: submodel
            });
          } else {
            nodeType = (function() {
              switch (action[0]) {
                case "inquiries":
                  return Inquiry;
                case "leases":
                  return Lease;
                case "units":
                  return Unit;
              }
            })();
            return (new Parse.Query(nodeType)).get(subid, {
              success: function(submodel) {
                return _this.renderSubView(name, {
                  property: _this.model,
                  model: submodel
                });
              }
            });
          }
        }
      };

      ShowPropertyView.prototype.renderSubView = function(name, vars) {
        var _this = this;
        if (this.subView) {
          this.subView.trigger("view:change");
        }
        this.$('.content').removeClass('in');
        return require([name], function(PropertySubView) {
          _this.subView = new PropertySubView(vars).render();
          return _this.$('.content').addClass('in');
        });
      };

      ShowPropertyView.prototype.refresh = function() {
        return $('#preview-profile-picture img').prop('src', this.model.cover('profile'));
      };

      ShowPropertyView.prototype.clear = function() {
        Parse.User.current().get("network").properties.trigger("close");
        this.undelegateEvents();
        this.remove();
        return delete this;
      };

      ShowPropertyView.prototype.editProfilePicture = function() {
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

      return ShowPropertyView;

    })(Parse.View);
  });

}).call(this);
