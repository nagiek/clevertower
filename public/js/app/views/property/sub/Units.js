(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/UnitList', 'models/Property', 'models/Unit', 'views/helper/Alert', 'views/unit/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/units', 'datepicker'], function($, _, Parse, UnitList, Property, Unit, Alert, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyUnitsView, _ref;

    return PropertyUnitsView = (function(_super) {
      __extends(PropertyUnitsView, _super);

      function PropertyUnitsView() {
        this.save = __bind(this.save, this);
        this.undo = __bind(this.undo, this);
        this.addX = __bind(this.addX, this);
        this.addOne = __bind(this.addOne, this);
        this.addAll = __bind(this.addAll, this);
        this.switchToEdit = __bind(this.switchToEdit, this);
        this.switchToShow = __bind(this.switchToShow, this);
        this.switchMode = __bind(this.switchMode, this);
        this.clear = __bind(this.clear, this);
        this.render = __bind(this.render, this);        _ref = PropertyUnitsView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyUnitsView.prototype.el = ".content";

      PropertyUnitsView.prototype.events = {
        'click #units-edit': 'switchMode',
        'click #add-x': 'addX',
        'click .undo': 'undo',
        'click .save': 'save'
      };

      PropertyUnitsView.prototype.initialize = function(attrs) {
        var _this = this;

        this.on("view:change", this.clear);
        this.listenTo(this.model.units, "add", this.addOne);
        this.listenTo(this.model.units, "reset", this.addAll);
        this.listenTo(this.model.units, "invalid", function(error) {
          var msg;

          switch (error.message) {
            case 'title_missing':
              _this.$('.title-group .control-group').addClass('error');
          }
          msg = (typeof error.code === "function" ? error.code(i18nCommon.errors[error.message]) : void 0) ? void 0 : i18nUnit.errors[error.message];
          return new Alert({
            event: 'unit-invalid',
            fade: false,
            message: msg,
            type: 'error'
          });
        });
        return this.editing = false;
      };

      PropertyUnitsView.prototype.render = function() {
        var today, vars;

        today = moment(new Date).format('L');
        vars = {
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          today: today
        };
        this.$el.html(JST["src/js/templates/property/sub/units.jst"](vars));
        this.$table = this.$("#units-table");
        this.$actions = this.$(".form-actions");
        this.$undo = this.$actions.find('.undo');
        if (this.model.units.length === 0) {
          this.model.units.fetch();
          this.switchToEdit();
        } else {
          this.addAll();
        }
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

      PropertyUnitsView.prototype.switchToShow = function(e) {
        if (this.editing) {
          return this.switchMode;
        }
      };

      PropertyUnitsView.prototype.switchToEdit = function(e) {
        if (!this.editing) {
          return this.switchMode;
        }
      };

      PropertyUnitsView.prototype.addAll = function(collection, filter) {
        this.$list = this.$("#units-table tbody");
        this.$list.html('');
        if (this.model.units.length > 0) {
          return this.model.units.each(this.addOne);
        } else {
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
          view.$('.view-specific').toggleClass('hide');
        }
        return this.$list.last().find('.title').focus();
      };

      PropertyUnitsView.prototype.addX = function(e) {
        var x;

        e.preventDefault();
        x = Number($('#x').val());
        if (x == null) {
          x = 1;
        }
        while (!(x <= 0)) {
          this.model.units.prepopulate();
          x--;
        }
        this.$undo.removeProp('disabled');
        return this.$list.last().find('.title').focus();
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
        return Parse.Object.saveAll(this.model.units, {
          success: function(units) {
            new Alert({
              event: 'units-save',
              fade: true,
              message: i18nCommon.actions.changes_saved,
              type: 'success'
            });
            return _this.model.units.trigger("save:success");
          },
          error: function(error) {
            return _this.model.units.trigger("invalid", unit, error);
          }
        });
      };

      return PropertyUnitsView;

    })(Parse.View);
  });

}).call(this);
