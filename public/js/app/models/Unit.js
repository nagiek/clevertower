(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['underscore', 'backbone', "models/Property", "i18n!nls/unit"], function(_, Parse, Property, i18nUnit) {
    var Unit;
    return Unit = (function(_super) {

      __extends(Unit, _super);

      function Unit() {
        return Unit.__super__.constructor.apply(this, arguments);
      }

      Unit.prototype.className = "Unit";

      Unit.prototype.defaults = {
        bathrooms: 0,
        bedrooms: 0,
        rent: 0,
        description: "",
        square_feet: "",
        title: "",
        appliances: "",
        confirmed: true
      };

      Unit.prototype.validate = function(attrs, options) {
        if (attrs == null) {
          attrs = {};
        }
        if (options == null) {
          options = {};
        }
        if (attrs.title && attrs.title === '') {
          return {
            message: 'title_missing'
          };
        }
        return false;
      };

      return Unit;

    })(Parse.Object);
  });

}).call(this);
