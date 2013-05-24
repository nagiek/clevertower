(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['underscore', 'backbone', "collections/LeaseList", "models/Property", "i18n!nls/unit"], function(_, Parse, LeaseList, Property, i18nUnit) {
    var Unit, _ref;

    return Unit = (function(_super) {
      __extends(Unit, _super);

      function Unit() {
        _ref = Unit.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Unit.prototype.className = "Unit";

      Unit.prototype.defaults = {
        bathrooms: 0,
        bedrooms: 0,
        rent: 0,
        square_feet: 0,
        title: "",
        description: "",
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

      Unit.prototype.prep = function(collectionName, options) {
        var property;

        if (this[collectionName]) {
          return this[collectionName];
        }
        this[collectionName] = (function() {
          switch (collectionName) {
            case "leases":
              property = this.get("property");
              if (property.leases) {
                return property.leases;
              } else {
                return new LeaseList([], {
                  unit: this
                });
              }
          }
        }).call(this);
        return this[collectionName];
      };

      return Unit;

    })(Parse.Object);
  });

}).call(this);
