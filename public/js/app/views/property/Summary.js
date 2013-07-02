(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", 'templates/property/summary', "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/building", "templates/property/menu/actions"], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var PropertySummaryView, _ref;

    return PropertySummaryView = (function(_super) {
      __extends(PropertySummaryView, _super);

      function PropertySummaryView() {
        this.render = __bind(this.render, this);
        this.updateTenantCount = __bind(this.updateTenantCount, this);
        this.updateListingCount = __bind(this.updateListingCount, this);
        this.updateUnitCount = __bind(this.updateUnitCount, this);        _ref = PropertySummaryView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertySummaryView.prototype.tagName = "li";

      PropertySummaryView.prototype.className = "row";

      PropertySummaryView.prototype.initialize = function() {
        this.model.prep('units');
        this.model.prep('listings');
        this.model.prep('tenants');
        this.listenTo(this.model.units, 'add reset', this.updateUnitCount);
        this.listenTo(this.model.listings, 'add reset', this.updateListingCount);
        return this.listenTo(this.model.tenants, 'add reset', this.updateTenantCount);
      };

      PropertySummaryView.prototype.updateUnitCount = function() {
        var units;

        units = this.model.units.where({
          property: this.model
        });
        this.$(".unit-count").html(units.length);
        return this.$(".vacant-count").html(_.filter(units, function(u) {
          return u.get("activeLease") === void 0;
        }).length);
      };

      PropertySummaryView.prototype.updateListingCount = function() {
        return this.$(".listings-count").html(this.model.listings.where({
          property: this.model
        }).length);
      };

      PropertySummaryView.prototype.updateTenantCount = function() {
        return this.$(".tenants-count").html(this.model.tenants.where({
          property: this.model
        }).length);
      };

      PropertySummaryView.prototype.render = function() {
        var units, vars;

        units = this.model.units.where({
          property: this.model
        });
        vars = _.merge(this.model.toJSON(), {
          cover: this.model.cover('profile'),
          publicUrl: this.model.publicUrl(),
          listings: this.model.listings.where({
            property: this.model
          }).length,
          tenants: this.model.tenants.where({
            property: this.model
          }).length,
          units: units.length,
          vacant_units: _.filter(units, function(u) {
            return u.get("activeLease") === void 0;
          }).length,
          baseUrl: "/properties/" + this.model.id,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        });
        this.$el.html(JST["src/js/templates/property/summary.jst"](vars));
        this.$("[rel=tooltip]").tooltip();
        return this;
      };

      return PropertySummaryView;

    })(Parse.View);
  });

}).call(this);
