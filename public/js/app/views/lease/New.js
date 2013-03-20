(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", "collections/unit/UnitList", "models/Property", "models/Unit", "models/Lease", "views/helper/Alert", "i18n!nls/common", "i18n!nls/unit", "i18n!nls/lease", "templates/lease/new", "templates/lease/_form", "templates/helper/field/unit", "templates/helper/field/property", "templates/helper/field/tenant"], function($, _, Parse, moment, UnitList, Property, Unit, Lease, Alert, i18nCommon, i18nUnit, i18nLease) {
    var NewLeaseView;
    return NewLeaseView = (function(_super) {

      __extends(NewLeaseView, _super);

      function NewLeaseView() {
        this.addAll = __bind(this.addAll, this);

        this.addToSelect = __bind(this.addToSelect, this);
        return NewLeaseView.__super__.constructor.apply(this, arguments);
      }

      NewLeaseView.prototype.el = '#content';

      NewLeaseView.prototype.events = {
        'click .save': 'save'
      };

      NewLeaseView.prototype.initialize = function(attrs) {
        if (!this.model) {
          this.model = new Lease;
        }
        this.property = attrs.property;
        if (!this.property.units) {
          this.units = new UnitList;
          this.units.query = new Parse.Query(Unit);
          this.units.query.equalTo("network", Parse.User.current().get("network"));
          this.units.comparator = function(unit) {
            var char, title;
            title = unit.get("title");
            char = title.charAt(title.length - 1);
            if (isNaN(char)) {
              return Number(title.substr(0, title.length - 1)) + char.charCodeAt() / 128;
            } else {
              return Number(title);
            }
          };
        } else {
          this.units = this.property.units;
        }
        this.render();
        this.$unitSelect = this.$('.unit-select');
        this.units.bind("add", this.addToSelect);
        this.units.bind("reset", this.addAll);
        return this.units.fetch();
      };

      NewLeaseView.prototype.addToSelect = function(unit) {
        var HTML;
        HTML = "<option value='" + unit.id + "'>" + (unit.get('title')) + "</option>";
        return this.$unitSelect.children(':last').before(HTML);
      };

      NewLeaseView.prototype.addAll = function() {
        if (this.$unitSelect.children().length > 2) {
          this.$unitSelect.html("<option value=''>" + i18nCommon.form.select.select_value + "</option>\n<option value='-1'>" + i18nUnit.constants.new_unit + "</option>");
        }
        return this.units.each(this.addToSelect);
      };

      NewLeaseView.prototype.save = function() {
        var _this = this;
        return this.model.save(this.$el.serializeObject().property, {
          success: function(property) {
            return _this.trigger("property:save", property, _this);
          },
          error: function(property, error) {
            _this.$el.find('.error').removeClass('error');
            new Alert({
              event: 'property-save',
              fade: false,
              message: i18nProperty.errors[error.message],
              type: 'error'
            });
            switch (error.message) {
              case 'title_missing':
                return _this.$el.find('#property-title-group').addClass('error');
            }
          }
        });
      };

      NewLeaseView.prototype.render = function() {
        var vars;
        vars = _.merge({
          lease: this.model,
          cancel_path: "/properties/" + this.property.id,
          units: this.units,
          moment: moment,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        console.log(this.$el);
        this.$el.html(JST["src/js/templates/lease/new.jst"](vars));
        return this;
      };

      return NewLeaseView;

    })(Parse.View);
  });

}).call(this);
