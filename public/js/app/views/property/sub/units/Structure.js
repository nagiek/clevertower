(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/unit/UnitList', 'models/Property', 'models/Unit', 'views/unit/Edit', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/units'], function($, _, Parse, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyUnitsView;
    return PropertyUnitsView = (function(_super) {

      __extends(PropertyUnitsView, _super);

      function PropertyUnitsView() {
        this.save = __bind(this.save, this);

        this.addX = __bind(this.addX, this);

        this.addOne = __bind(this.addOne, this);

        this.render = __bind(this.render, this);
        return PropertyUnitsView.__super__.constructor.apply(this, arguments);
      }

      PropertyUnitsView.prototype.el = "#content";

      PropertyUnitsView.prototype.events = {
        'click #add-x': 'addX',
        'click .save': 'save'
      };

      PropertyUnitsView.prototype.initialize = function(attrs) {
        var vars,
          _this = this;
        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/property/sub/units.jst"](vars));
        this.messages = $("#messages");
        this.$list = this.$el.find("#units-form tbody");
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
        this.units.fetch({
          success: function(collection, response, options) {
            if (collection.length === 0) {
              return _this.units.add([
                {
                  property: _this.model
                }
              ]);
            }
          }
        });
        return this.render();
      };

      PropertyUnitsView.prototype.render = function() {
        this.$list.html("");
        if (this.units.length !== 0) {
          return this.units.each(this.addOne);
        } else {
          return this.$list.html('<p class="empty">' + i18nUnit.collection.empty + '</p>');
        }
      };

      PropertyUnitsView.prototype.addOne = function(unit) {
        var view;
        view = new UnitView({
          model: unit
        });
        return this.$list.append(view.render().el);
      };

      PropertyUnitsView.prototype.addX = function(e) {
        var inc, title, unit, x, _results;
        e.preventDefault();
        x = Number($('#x').val());
        inc = Number($('#increment').val());
        if (x == null) {
          x = 1;
        }
        _results = [];
        while (!(x <= 0)) {
          unit = this.units.length === 0 ? {
            title: title,
            property: this.model
          } : this.units.at(this.units.length - 1).clone();
          title = Number(unit.get('title'));
          if (_.isNumber(title)) {
            unit.set('title', title + inc);
          }
          this.units.add(unit);
          _results.push(x--);
        }
        return _results;
      };

      PropertyUnitsView.prototype.save = function(e) {
        var _this = this;
        e.preventDefault();
        this.units.each(function(unit) {
          return unit.save(null, {
            success: function() {},
            error: function() {
              _this.messages.addClass('alert-error').show().html(i18nCommon.form.erros.changes_saved).delay(3000).fadeOut().children().removeClass('alert-error');
            }
          });
        });
        return this.messages.addClass('alert-success').show().html(i18nCommon.actions.changes_saved).delay(3000).fadeOut().children().removeClass('alert-success');
      };

      return PropertyUnitsView;

    })(Parse.View);
  });

}).call(this);
