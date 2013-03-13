(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'collections/unit/UnitList', 'models/Property', 'models/Unit', 'views/unit/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/current'], function($, _, Parse, moment, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyCurrentView;
    return PropertyCurrentView = (function(_super) {

      __extends(PropertyCurrentView, _super);

      function PropertyCurrentView() {
        this.addOne = __bind(this.addOne, this);

        this.render = __bind(this.render, this);
        return PropertyCurrentView.__super__.constructor.apply(this, arguments);
      }

      PropertyCurrentView.prototype.el = "#content";

      PropertyCurrentView.prototype.initialize = function(attrs) {
        var vars;
        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/property/sub/current.jst"](vars));
        this.$list = this.$el.find("#current-units tbody");
        this.units = new UnitList({
          property: this.model
        });
        this.units.query = new Parse.Query(Unit);
        this.units.query.equalTo("property", this.model);
        this.units.comparator = function(unit) {
          return unit.get("title");
        };
        this.units.bind("add", this.addOne);
        this.units.bind("reset", this.render);
        this.units.fetch();
        return this.render();
      };

      PropertyCurrentView.prototype.render = function() {
        this.$list.html("");
        if (this.units.length !== 0) {
          this.units.each(this.addOne);
          this.$list.children(':even').addClass('views-row-even');
          return this.$list.children(':odd').addClass('views-row-odd');
        } else {
          return this.$list.html('<p class="empty">' + i18nUnit.collection.empty + '</p>');
        }
      };

      PropertyCurrentView.prototype.addOne = function(unit) {
        var view;
        view = new UnitView({
          model: unit
        });
        return this.$list.append(view.render().el);
      };

      return PropertyCurrentView;

    })(Parse.View);
  });

}).call(this);
