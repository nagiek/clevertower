(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", 'views/helper/Alert', "i18n!nls/property", "i18n!nls/common", "plugins/toggler", "templates/property/sub/edit", 'templates/property/_form'], function($, _, Parse, Property, Alert, i18nProperty, i18nCommon) {
    var PropertyEditView;
    return PropertyEditView = (function(_super) {

      __extends(PropertyEditView, _super);

      function PropertyEditView() {
        this.render = __bind(this.render, this);

        this.clear = __bind(this.clear, this);
        return PropertyEditView.__super__.constructor.apply(this, arguments);
      }

      PropertyEditView.prototype.el = ".content";

      PropertyEditView.prototype.events = {
        'submit form': 'save',
        'click .remove': 'kill'
      };

      PropertyEditView.prototype.initialize = function() {
        _.bindAll(this, 'save');
        this.on("property:save", function() {
          return new Alert({
            event: 'model-save',
            fade: true,
            message: i18nCommon.actions.changes_saved,
            type: 'success'
          });
        });
        this.on("property:sync", function() {
          return this.$('button.save').removeProp('disabled');
        });
        return this.model.on("invalid", function(error) {
          new Alert({
            event: 'model-save',
            fade: false,
            message: i18nProperty.errors[error.message],
            type: 'error'
          });
          switch (error.message) {
            case 'title_missing':
              return this.$el.find('#property-title-group').addClass('error');
          }
        });
      };

      PropertyEditView.prototype.clear = function(e) {
        this.undelegateEvents();
        return delete this;
      };

      PropertyEditView.prototype.render = function() {
        var vars;
        vars = {
          property: _.defaults(this.model.attributes, Property.prototype.defaults),
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        };
        vars.property.id = this.model.id;
        this.$el.html(JST["src/js/templates/property/sub/edit.jst"](vars));
        this.$('.toggle').toggler();
        return this;
      };

      PropertyEditView.prototype.save = function(e) {
        var attrs,
          _this = this;
        e.preventDefault();
        this.$('.error').removeClass('error');
        this.$('button.save').prop('disabled', 'disabled');
        attrs = this.$('form').serializeObject().property;
        attrs["public"] = attrs["public"] === "1" ? true : false;
        return this.model.save(attrs, {
          success: function(property) {
            _this.trigger("property:sync", property, _this);
            return _this.trigger("property:save", property, _this);
          },
          error: function(property, error) {
            _this.trigger("property:sync", property, _this);
            return _this.model.trigger("invalid", error, _this);
          }
        });
      };

      PropertyEditView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)) {
          this.model.destroy();
          this.remove();
          Parse.history.navigate("/", true);
          return this.clear();
        }
      };

      return PropertyEditView;

    })(Parse.View);
  });

}).call(this);
