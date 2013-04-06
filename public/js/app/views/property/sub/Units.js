(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/unit/UnitList', 'models/Property', 'models/Unit', 'views/helper/Alert', 'views/unit/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/units', 'datepicker'], function($, _, Parse, UnitList, Property, Unit, Alert, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyUnitsView;
    return PropertyUnitsView = (function(_super) {

      __extends(PropertyUnitsView, _super);

      function PropertyUnitsView() {
        this.save = __bind(this.save, this);

        this.undo = __bind(this.undo, this);

        this.addX = __bind(this.addX, this);

        this.addOne = __bind(this.addOne, this);

        this.addAll = __bind(this.addAll, this);

        this.switchMode = __bind(this.switchMode, this);

        this.clear = __bind(this.clear, this);

        this.render = __bind(this.render, this);
        return PropertyUnitsView.__super__.constructor.apply(this, arguments);
      }

      PropertyUnitsView.prototype.el = ".content";

      PropertyUnitsView.prototype.events = {
        'click #units-edit': 'switchMode',
        'click #add-x': 'addX',
        'click .undo': 'undo',
        'click .save': 'save'
      };

      PropertyUnitsView.prototype.initialize = function(attrs) {
        this.editing = false;
        this.on("view:change", this.clear);
        this.model.load('units');
        this.model.units.on("add", this.addOne);
        return this.model.units.on("reset", this.addAll);
      };

      PropertyUnitsView.prototype.render = function() {
        var today, vars;
        today = moment(new Date).format('L');
        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          today: today
        });
        this.$el.html(JST["src/js/templates/property/sub/units.jst"](vars));
        this.$table = this.$("#units-table");
        this.$list = this.$("#units-table tbody");
        this.$actions = this.$(".form-actions");
        this.$undo = this.$actions.find('.undo');
        return this;
      };

      PropertyUnitsView.prototype.clear = function(e) {
        this.undelegateEvents();
        return delete this;
      };

      PropertyUnitsView.prototype.switchMode = function(e) {
        e.preventDefault();
        this.$('#units-edit').toggleClass('active');
        this.$table.find('.view-specific').toggleClass('hide');
        this.$actions.toggleClass('hide');
        return this.editing = this.editing ? false : true;
      };

      PropertyUnitsView.prototype.addAll = function(collection, filter) {
        this.$list.html('');
        this.model.units.each(this.addOne);
        if (this.model.units.length === 0) {
          return this.$list.html('<p class="empty">' + i18nProperty.collection.empty.units + '</p>');
        }
      };

      PropertyUnitsView.prototype.addOne = function(unit) {
        var view;
        this.$('p.empty').hide();
        view = new UnitView({
          model: unit
        });
        this.$list.append(view.render().el);
        if (this.editing) {
          return view.$('.view-specific').toggleClass('hide');
        }
      };

      PropertyUnitsView.prototype.addX = function(e) {
        var char, newChar, newTitle, title, unit, x;
        e.preventDefault();
        x = Number($('#x').val());
        if (x == null) {
          x = 1;
        }
        while (!(x <= 0)) {
          if (this.model.units.length === 0) {
            unit = new Unit({
              property: this.model
            });
          } else {
            unit = this.model.units.at(this.model.units.length - 1).clone();
            unit.set("has_lease", false);
            unit.unset("activeLease");
            title = unit.get('title');
            newTitle = title.substr(0, title.length - 1);
            char = title.charAt(title.length - 1);
            newChar = isNaN(char) ? String.fromCharCode(char.charCodeAt() + 1) : String(Number(char) + 1);
            unit.set('title', newTitle + newChar);
          }
          this.model.units.add(unit);
          x--;
        }
        this.$undo.removeProp('disabled');
        return this.$list.last().find('.title-group input').focus();
      };

      PropertyUnitsView.prototype.undo = function(e) {
        var x;
        e.preventDefault();
        x = Number($('#x').val());
        if (x == null) {
          x = 1;
        }
        while (!(x <= 0)) {
          if (this.model.units.length !== 0) {
            if (this.model.units.last().isNew()) {
              this.model.units.last().destroy();
            }
          }
          x--;
        }
        return this.$undo.prop('disabled', 'disabled');
      };

      PropertyUnitsView.prototype.save = function(e) {
        var _this = this;
        e.preventDefault();
        if (this.$('.error')) {
          this.$('.error').removeClass('error');
        }
        return this.model.units.each(function(unit) {
          return unit.save(null, {
            success: function(unit) {
              new Alert({
                event: 'units-save',
                fade: true,
                message: i18nCommon.actions.changes_saved,
                type: 'success'
              });
              if (unit.changed) {
                return unit.trigger("save:success");
              }
            },
            error: function(unit, error) {
              return unit.trigger("invalid", unit, error);
            }
          });
        });
      };

      return PropertyUnitsView;

    })(Parse.View);
  });

}).call(this);
