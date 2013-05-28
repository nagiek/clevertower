(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", 'templates/property/form', 'templates/property/form_tenant'], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var NewPropertyView, _ref;

    return NewPropertyView = (function(_super) {
      __extends(NewPropertyView, _super);

      function NewPropertyView() {
        this.clear = __bind(this.clear, this);        _ref = NewPropertyView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      NewPropertyView.prototype.tagName = "form";

      NewPropertyView.prototype.className = "property-form span12";

      NewPropertyView.prototype.initialize = function(attrs) {
        this.wizard = attrs.wizard;
        this.listenTo(this.wizard, "wizard:cancel", this.clear);
        return this.listenTo(this.wizard, "property:save", this.clear);
      };

      NewPropertyView.prototype.render = function() {
        var networkVars, template, vars;

        _.defaults(this.model.attributes, Property.prototype.defaults);
        if (Parse.User.current() && Parse.User.current().get("network")) {
          networkVars = {
            email: Parse.User.current().get("network").get("email"),
            phone: Parse.User.current().get("network").get("phone"),
            website: Parse.User.current().get("network").get("website")
          };
          _.defaults(this.model.attributes, networkVars);
          template = "src/js/templates/property/form.jst";
        } else {
          template = "src/js/templates/property/form_tenant.jst";
        }
        vars = {
          property: this.model.attributes,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        };
        this.$el.html(JST[template](vars));
        return this;
      };

      NewPropertyView.prototype.clear = function() {
        this.undelegateEvents();
        this.remove();
        return delete this;
      };

      return NewPropertyView;

    })(Parse.View);
  });

}).call(this);
