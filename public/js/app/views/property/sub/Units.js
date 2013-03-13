(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/unit/UnitList', 'models/Property', 'models/Unit', 'views/unit/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/units'], function($, _, Parse, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyUnitsView;
    return PropertyUnitsView = (function(_super) {

      __extends(PropertyUnitsView, _super);

      function PropertyUnitsView() {
        this.save = __bind(this.save, this);

        this.addX = __bind(this.addX, this);

        this.addOne = __bind(this.addOne, this);

        this.addAll = __bind(this.addAll, this);

        this.switchToEdit = __bind(this.switchToEdit, this);

        this.switchToShow = __bind(this.switchToShow, this);

        this.render = __bind(this.render, this);
        return PropertyUnitsView.__super__.constructor.apply(this, arguments);
      }

      PropertyUnitsView.prototype.el = "#content";

      PropertyUnitsView.prototype.events = {
        'click #units-show a': 'switchToShow',
        'click #units-edit a': 'switchToEdit',
        'click #add-x': 'addX',
        'click .save': 'save'
      };

      PropertyUnitsView.prototype.initialize = function(attrs) {
        var vars;
        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/property/sub/units.jst"](vars));
        this.editing = false;
        this.$messages = $("#messages");
        this.$table = this.$("#units-table");
        this.$list = this.$("#units-table tbody");
        this.$actions = this.$(".form-actions");
        this.units = new UnitList({
          property: this.model
        });
        this.units.query = new Parse.Query(Unit);
        this.units.query.equalTo("property", this.model);
        this.units.comparator = function(unit) {
          return Number(unit.get("title"));
        };
        this.units.bind("add", this.addOne);
        this.units.bind("reset", this.addAll);
        return this.units.fetch();
      };

      PropertyUnitsView.prototype.render = function() {
        this.$list.html("");
        if (this.units.length === 0) {
          return this.$list.html('<p class="empty">' + i18nUnit.collection.empty + '</p>');
        }
      };

      PropertyUnitsView.prototype.switchToShow = function(e) {
        e.preventDefault();
        if (!this.editing) {
          return;
        }
        this.$('ul.nav').children().removeClass('active');
        e.currentTarget.parentNode.className = 'active';
        this.$table.find('.view-specific').toggleClass('hide');
        this.$actions.toggleClass('hide');
        this.editing = false;
        return e;
      };

      PropertyUnitsView.prototype.switchToEdit = function(e) {
        e.preventDefault();
        if (this.editing) {
          return;
        }
        this.$('ul.nav').children().removeClass('active');
        e.currentTarget.parentNode.className = 'active';
        this.$table.find('.view-specific').toggleClass('hide');
        this.$actions.toggleClass('hide');
        this.editing = true;
        return e;
      };

      PropertyUnitsView.prototype.addAll = function(collection, filter) {
        this.render();
        return this.units.each(this.addOne);
      };

      PropertyUnitsView.prototype.addOne = function(unit) {
        var view;
        this.$('p.empty').hide();
        view = new UnitView({
          model: unit
        });
        this.$list.append(view.render().el);
        if (this.editing) {
          return view.$el.find('.view-specific').toggleClass('hide');
        }
      };

      PropertyUnitsView.prototype.addX = function(e) {
        var inc, title, unit, x;
        e.preventDefault();
        x = Number($('#x').val());
        inc = Number($('#increment').val());
        if (x == null) {
          x = 1;
        }
        if (inc == null) {
          inc = 0;
        }
        while (!(x <= 0)) {
          if (this.units.length === 0) {
            unit = new Unit({
              property: this.model
            });
          } else {
            unit = this.units.at(this.units.length - 1).clone();
            title = unit.get('title');
            if (_.isNumber(title) && title !== '') {
              unit.set('title', String(Number(title + inc)));
            }
          }
          this.units.add(unit);
          x--;
        }
        return this.$list.last().find('.title-group input').focus();
      };

      PropertyUnitsView.prototype.save = function(e) {
        var _this = this;
        e.preventDefault();
        return this.units.each(function(unit) {
          var error;
          if (unit.changed) {
            error = unit.validate(unit.attributes);
            if (!error) {
              return unit.save(null, {
                success: function(unit) {
                  if (!_this.$messages.hasClass('alert-error')) {
                    _this.$messages.addClass('alert-success').show().html(i18nCommon.actions.changes_saved).delay(3000).fadeOut();
                  }
                  if (unit.changed) {
                    return unit.trigger("save:success");
                  }
                },
                error: function(unit, error) {
                  return unit.trigger("invalid", unit, error);
                }
              });
            } else {
              return unit.trigger("invalid", unit, error);
            }
          }
        });
      };

      return PropertyUnitsView;

    })(Parse.View);
  });

}).call(this);
