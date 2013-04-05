(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", "collections/tenant/TenantList", "models/Property", "models/Unit", "models/Lease", "models/Tenant", "views/helper/Alert", "i18n!nls/common", "i18n!nls/unit", "i18n!nls/lease", "templates/lease/new", "templates/lease/edit", "templates/lease/_form", "templates/helper/field/unit", "templates/helper/field/property", "templates/helper/field/tenant", "datepicker"], function($, _, Parse, moment, TenantList, Property, Unit, Lease, Tenant, Alert, i18nCommon, i18nUnit, i18nLease) {
    var NewLeaseView;
    return NewLeaseView = (function(_super) {

      __extends(NewLeaseView, _super);

      function NewLeaseView() {
        this.showUnitIfNew = __bind(this.showUnitIfNew, this);

        this.addAll = __bind(this.addAll, this);

        this.addOne = __bind(this.addOne, this);
        return NewLeaseView.__super__.constructor.apply(this, arguments);
      }

      NewLeaseView.prototype.el = '.content';

      NewLeaseView.prototype.events = {
        'submit .lease-form': 'save',
        'click .starting-this-month': 'setThisMonth',
        'click .starting-next-month': 'setNextMonth',
        'click .july-to-june': 'setJulyJune',
        'change .unit-select': 'showUnitIfNew'
      };

      NewLeaseView.prototype.initialize = function(attrs) {
        var _this = this;
        _.bindAll(this, 'addOne', 'addAll', 'save', 'setThisMonth', 'setNextMonth', 'setJulyJune');
        if (!this.model) {
          this.model = new Lease;
        }
        if (!this.model.tenants) {
          this.model.tenants = new TenantList;
        }
        this.property = attrs.property;
        this.model.on('invalid', function(error) {
          var args, fn, msg;
          _this.$('.error').removeClass('error');
          _this.$('button.save').removeProp("disabled");
          msg = (function() {
            if (error.message) {
              if (error.message.indexOf(":") > 0) {
                args = error.message.split(":");
                fn = args.pop();
                switch (fn) {
                  case "overlapping_dates":
                    return i18nLease.errors[fn]("/properties/" + this.property.id + "/leases/" + args[0]);
                  default:
                    return i18nLease.errors[fn](args[0]);
                }
              } else {
                return i18nLease.errors[error.message];
              }
            } else {
              return i18nCommon.errors.unknown;
            }
          }).call(_this);
          new Alert({
            event: 'model-save',
            fade: false,
            message: msg,
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
          _this.model.tenants.fetch();
          new Alert({
            event: 'model-save',
            fade: true,
            message: i18nCommon.actions.changes_saved,
            type: 'success'
          });
          new ShowLeaseView({
            model: model
          });
          Parse.history.navigate("/properties/" + _this.property.id + "/leases/" + model.id);
          _this.undelegateEvents();
          return delete _this;
        });
        this.model.on('destroy', function() {
          _this.undelegateEvents();
          return delete _this;
        });
        if (this.property) {
          this.property.load("units");
          this.units = this.property.units;
        }
        this.current = new Date().setDate(1);
        this.dates = {
          start: this.model.get("start_date") ? moment(this.model.get("start_date")).format("L") : moment(this.current).format("L"),
          end: this.model.get("end_date") ? moment(this.model.get("end_date")).format("L") : moment(this.current).add(1, 'year').subtract(1, 'day').format("L")
        };
        this.render();
        this.$unitSelect = this.$('.unit-select');
        this.$startDate = this.$('.start-date');
        this.$endDate = this.$('.end-date');
        $('.datepicker').datepicker();
        this.units.bind("add", this.addOne);
        this.units.bind("reset", this.addAll);
        return this.units.fetch();
      };

      NewLeaseView.prototype.addOne = function(u) {
        var HTML;
        HTML = ("<option value='" + u.id + "'") + (this.model.get("unit") && this.model.get("unit").id === u.id ? "selected='selected'" : "") + (">" + (u.get('title')) + "</option>");
        return this.$unitSelect.children(':first').after(HTML);
      };

      NewLeaseView.prototype.addAll = function() {
        if (this.$unitSelect.children().length > 2) {
          this.$unitSelect.html("<option value=''>" + i18nCommon.form.select.select_value + "</option>\n<option value='-1'>" + i18nUnit.constants.new_unit + "</option>");
        }
        return this.units.each(this.addOne);
      };

      NewLeaseView.prototype.save = function(e) {
        var attrs, data, unit, userValid,
          _this = this;
        e.preventDefault();
        this.$('button.save').prop("disabled", "disabled");
        data = this.$('form').serializeObject();
        this.$('.error').removeClass('error');
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
            data.lease[attr] = moment(data.lease[attr], i18nCommon.dates.moment_format).toDate();
          }
          if (typeof data.lease[attr] === 'string') {
            return data.lease[attr] = new Date;
          }
        });
        _.each(['checks_received', 'first_month_paid', 'last_month_paid'], function(attr) {
          return data.lease[attr] = data.lease[attr] !== "" ? true : false;
        });
        attrs = data.lease;
        if (data.unit && data.unit.id !== "") {
          if (data.unit.id === "-1") {
            unit = new Unit(data.unit.attributes);
            unit.set("property", this.property);
          } else {
            unit = this.units.get(data.unit.id);
          }
          attrs.unit = unit;
        }
        userValid = true;
        if (data.emails && data.emails !== '') {
          attrs.emails = [];
          _.each(data.emails.split(","), function(email) {
            var account;
            email = $.trim(email);
            account = new Parse.User({
              username: email,
              email: email
            });
            if (userValid = account.isValid()) {
              return attrs.emails.push(email);
            }
          });
        }
        if (!userValid) {
          this.$('.emails-group').addClass('error');
          return this.model.trigger("invalid", {
            message: 'tenants_incorrect'
          });
        } else {
          return this.model.save(attrs, {
            success: function(model) {
              return _this.trigger("save:success", model, _this);
            },
            error: function(model, error) {
              return _this.model.trigger("invalid", error);
            }
          });
        }
      };

      NewLeaseView.prototype.showUnitIfNew = function(e) {
        if (e.target.value === "-1") {
          return this.$('.new-unit').removeClass('hide');
        } else {
          return this.$('.new-unit').addClass('hide');
        }
      };

      NewLeaseView.prototype.setThisMonth = function() {
        this.$startDate.val(moment(this.current).format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setNextMonth = function() {
        this.$startDate.val(moment(this.current).add(1, 'month').format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setJulyJune = function() {
        this.$startDate.val(moment(this.current).month(6).format("L"));
        return this.$endDate.val(moment(this.current).month(6).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.render = function() {
        var vars;
        vars = _.merge({
          lease: this.model,
          dates: this.dates,
          cancel_path: ("/properties/" + this.property.id) + (!this.model.isNew() ? "/leases/" + this.model.id : ""),
          moment: moment,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        vars.unit = this.model.get("unit") ? this.model.get("unit") : false;
        return this.$el.html(JST["src/js/templates/lease/" + (this.model.isNew() ? 'new' : 'edit') + ".jst"](vars));
      };

      return NewLeaseView;

    })(Parse.View);
  });

}).call(this);
