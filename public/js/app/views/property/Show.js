(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", "underscore.inflection", 'templates/property/show', "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/building", "templates/property/menu/actions"], function($, _, Parse, Property, i18nProperty, i18nCommon, inflection) {
    var PropertyView;
    return PropertyView = (function(_super) {

      __extends(PropertyView, _super);

      function PropertyView() {
        this.clear = __bind(this.clear, this);

        this.renderSubView = __bind(this.renderSubView, this);

        this.changeSubView = __bind(this.changeSubView, this);
        return PropertyView.__super__.constructor.apply(this, arguments);
      }

      PropertyView.prototype.tagName = "div";

      PropertyView.prototype.id = "property";

      PropertyView.prototype.events = {
        'click .edit-profile-picture': 'editProfilePicture',
        'click h1 a': 'changeSubView',
        'click .nav .dropdown-menu a': 'changeSubView',
        'click .content a': 'changeSubView'
      };

      PropertyView.prototype.initialize = function(attrs) {
        var _this = this;
        $('.home').on('click', this.clear);
        this.$form = $("#profile-picture-upload");
        this.model.on('change:image_profile', function(model, name) {
          return _this.refresh;
        });
        this.model.on('destroy', this.clear);
        return this.changeSubView(attrs.e);
      };

      PropertyView.prototype.render = function() {
        var vars;
        vars = _.merge(this.model.toJSON(), {
          cover: this.model.cover('profile'),
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        });
        this.$el.html(JST["src/js/templates/property/show.jst"](vars));
        return this;
      };

      PropertyView.prototype.changeSubView = function(e) {
        var action, combo, d, node, origSubViewName, pair, queryComponents, querystring, subaction, urlComponents, vars, _i, _len;
        origSubViewName = this.subViewName;
        urlComponents = e.currentTarget.pathname.substring(1).split("/");
        action = urlComponents.length > 2 ? urlComponents.slice(2) : new Array('units');
        if (action.length > 1 && action[0] !== "add") {
          node = inflection.singularize[action[0]];
          subaction = action[2] ? action[2] : "show";
          vars = {
            property: this.model,
            subId: action[1]
          };
          this.subViewName = "views/" + node + "/" + subaction;
        } else {
          if (action[0] === "add") {
            this.model.loadUnits();
          }
          vars = {
            model: this.model
          };
          this.subViewName = "views/property/sub/" + (action.join("/"));
        }
        if (this.subViewName === origSubViewName) {
          return;
        }
        querystring = e.currentTarget.search;
        if (querystring.length > 0) {
          queryComponents = querystring.substring(1).split('&');
          vars.params = {};
          d = decodeURIComponent;
          for (_i = 0, _len = queryComponents.length; _i < _len; _i++) {
            combo = queryComponents[_i];
            pair = combo.split('=');
            vars.params[d(pair[0])] = d(pair[1]);
          }
        }
        return this.renderSubView(vars);
      };

      PropertyView.prototype.renderSubView = function(vars) {
        var _this = this;
        if (this.subView) {
          this.subView.trigger("view:change");
        }
        return require([this.subViewName], function(PropertySubView) {
          _this.subView = new PropertySubView(vars);
          _this.subView.render();
          return _this.delegateEvents();
        });
      };

      PropertyView.prototype.refresh = function() {
        return $('#preview-profile-picture img').prop('src', this.model.cover('profile'));
      };

      PropertyView.prototype.clear = function() {
        this.model.collection.trigger("close");
        this.undelegateEvents();
        this.remove();
        return delete this;
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
