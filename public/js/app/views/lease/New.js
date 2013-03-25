(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", "collections/unit/UnitList", "collections/tenant/TenantList", "models/Property", "models/Unit", "models/Lease", "models/Tenant", "views/helper/Alert", "i18n!nls/common", "i18n!nls/unit", "i18n!nls/lease", "templates/lease/new", "templates/lease/_form", "templates/helper/field/unit", "templates/helper/field/property", "templates/helper/field/tenant", "datepicker"], function($, _, Parse, moment, UnitList, TenantList, Property, Unit, Lease, Tenant, Alert, i18nCommon, i18nUnit, i18nLease) {
    var NewLeaseView;
    return NewLeaseView = (function(_super) {

      __extends(NewLeaseView, _super);

      function NewLeaseView() {
        this.setJulyJune = __bind(this.setJulyJune, this);

        this.setNextMonth = __bind(this.setNextMonth, this);

        this.setThisMonth = __bind(this.setThisMonth, this);

        this.showUnitIfNew = __bind(this.showUnitIfNew, this);

        this.save = __bind(this.save, this);

        this.addAll = __bind(this.addAll, this);

        this.addToSelect = __bind(this.addToSelect, this);
        return NewLeaseView.__super__.constructor.apply(this, arguments);
      }

      NewLeaseView.prototype.el = '#content';

      NewLeaseView.prototype.events = {
        'click .save': 'save',
        'change .unit-select': 'showUnitIfNew',
        'click .starting-this-month': 'setThisMonth',
        'click .starting-next-month': 'setNextMonth',
        'click .july-to-june': 'setJulyJune'
      };

      NewLeaseView.prototype.initialize = function(attrs) {
        var _this = this;
        if (!this.model) {
          this.model = new Lease;
        }
        if (!this.model.tenants) {
          this.model.tenants = new TenantList;
        }
        this.property = attrs.property;
        this.model.on('invalid', function(error) {
          _this.$el.find('.error').removeClass('error');
          new Alert({
            event: 'lease-save',
            fade: false,
            message: i18nLease.errors[error.message],
            type: 'error'
          });
          switch (error.message) {
            case 'unit_missing':
              return _this.$('.unit-group').addClass('error');
            case 'dates_missing' || 'dates_incorrect':
              return _this.$('.date-group').addClass('error');
          }
        });
        this.on("save:success", function(model) {
          _this.model.tenants.createQuery(model);
          _this.model.tenants.each(function(t) {
            return t.save();
          });
          new Alert({
            event: 'units-save',
            fade: true,
            message: i18nCommon.actions.changes_saved,
            type: 'success'
          });
          Parse.history.navigate("/properties/" + _this.property.id + "/leases/" + model.id);
          _this.remove();
          _this.undelegateEvents();
          return delete _this;
        });
        this.model.on('destroy', function() {
          _this.remove();
          _this.undelegateEvents();
          return delete _this;
        });
        if (!this.property.units) {
          this.units = new UnitList;
          this.units.query = new Parse.Query(Unit);
          this.units.query.equalTo("network", Parse.User.current().get("network"));
        } else {
          this.units = this.property.units;
        }
        this.current = new Date().setDate(1);
        this.dates = {
          start: this.model.get("start_date") ? this.model.get("start_date") : moment(this.current).format("L"),
          end: this.model.get("end_date") ? this.model.get("end_date") : moment(this.current).add(1, 'year').subtract(1, 'day').format("L")
        };
        this.render();
        this.$unitSelect = this.$('.unit-select');
        this.$startDate = this.$('.start-date');
        this.$endDate = this.$('.end-date');
        $('.datepicker').datepicker();
        this.units.bind("add", this.addToSelect);
        this.units.bind("reset", this.addAll);
        return this.units.fetch();
      };

      NewLeaseView.prototype.addToSelect = function(u) {
        var HTML;
        HTML = ("<option value='" + u.id + "'") + (this.model.get("unit") && this.model.get("unit").id === u.id ? "selected='selected'" : "") + (">" + (u.get('title')) + "</option>");
        return this.$unitSelect.children(':last').before(HTML);
      };

      NewLeaseView.prototype.addAll = function() {
        if (this.$unitSelect.children().length > 2) {
          this.$unitSelect.html("<option value=''>" + i18nCommon.form.select.select_value + "</option>\n<option value='-1'>" + i18nUnit.constants.new_unit + "</option>");
        }
        return this.units.each(this.addToSelect);
      };

      NewLeaseView.prototype.save = function(e) {
        var data, unit,
          _this = this;
        e.preventDefault();
        data = this.$('form').serializeObject();
        _.each(['rent', 'keys', 'garage_remotes', 'security_deposit', 'parking_fee'], function(attr) {
          if (data.lease[attr] === '') {
            data.lease[attr] = 0;
          }
          if (data.lease[attr] && isNaN(data.lease[attr])) {
            return data.lease[attr] = Number(data.lease[attr]);
          }
        });
        _.each(['start_date', 'end_date'], function(attr) {
          if (data.lease[attr] !== '') {
            data.lease[attr] = moment(data.lease[attr], i18nCommon.dates.datepicker_format).toDate();
          }
          if (typeof data.lease[attr] === 'string') {
            return data.lease[attr] = new Date;
          }
        });
        _.each(['checks_received', 'first_month_paid', 'last_month_paid'], function(attr) {
          return data.lease[attr] = data.lease[attr] !== "" ? true : false;
        });
        this.model.set(data.lease);
        if (data.unit && data.unit.id !== "") {
          if (data.unit.id === "-1") {
            unit = new Unit(data.unit.attributes);
            unit.set("property", this.property);
          } else {
            unit = this.units.get(data.unit.id);
          }
          this.model.set("unit", unit);
        }
        if (data.emails && data.emails !== '') {
          _.each(data.emails.split(","), function(email) {
            return _this.model.tenants.add(new Parse.User({
              email: $.trim(email)
            }));
          });
        }
        return this.model.save(null, {
          success: function(model) {
            return _this.trigger("save:success", model, _this);
          },
          error: function(model, error) {
            console.log(error);
            return _this.model.trigger("invalid", error);
          }
        });
      };

      NewLeaseView.prototype.showUnitIfNew = function(e) {
        if (e.target.value === "-1") {
          return this.$('.new-unit').removeClass('hide');
        } else {
          return this.$('.new-unit').addClass('hide');
        }
      };

      NewLeaseView.prototype.setThisMonth = function(e) {
        if (e) {
          e.preventDefault();
        }
        this.$startDate.val(moment(this.current).format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setNextMonth = function(e) {
        if (e) {
          e.preventDefault();
        }
        this.$startDate.val(moment(this.current).add(1, 'month').format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setJulyJune = function(e) {
        if (e) {
          e.preventDefault();
        }
        this.$startDate.val(moment(this.current).month(6).format("L"));
        return this.$endDate.val(moment(this.current).month(6).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.render = function() {
        var vars;
        vars = _.merge({
          lease: this.model,
          dates: this.dates,
          cancel_path: "/properties/" + this.property.id,
          units: this.units,
          moment: moment,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        vars.unit = this.model.get("unit") ? this.model.get("unit") : false;
        this.$el.html(JST["src/js/templates/lease/new.jst"](vars));
        return this;
      };

      return NewLeaseView;

    })(Parse.View);
  });

}).call(this);
