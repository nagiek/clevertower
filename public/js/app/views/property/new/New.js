(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", 'templates/property/_form'], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var NewPropertyView;
    return NewPropertyView = (function(_super) {

      __extends(NewPropertyView, _super);

      function NewPropertyView() {
        return NewPropertyView.__super__.constructor.apply(this, arguments);
      }

      NewPropertyView.prototype.el = ".property-form";

      NewPropertyView.prototype.initialize = function(attrs) {
        var _this = this;
        this.wizard = attrs.wizard;
        this.wizard.on("wizard:cancel", function() {
          _this.undelegateEvents();
          _this.remove();
          delete _this.model;
          return delete _this;
        });
        return this.wizard.on("property:save", function() {
          _this.undelegateEvents();
          _this.remove();
          delete _this.model;
          return delete _this;
        });
      };

      NewPropertyView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/property/_form.jst"]({
          property: this.model,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        }));
        return this;
      };

      return NewPropertyView;

    })(Parse.View);
  });

}).call(this);
