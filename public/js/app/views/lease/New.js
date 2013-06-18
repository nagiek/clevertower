(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", "models/Property", "models/Unit", "models/Lease", "models/Tenant", "views/helper/Alert", "i18n!nls/common", "i18n!nls/unit", "i18n!nls/lease", "templates/lease/new", "templates/lease/new-modal", "templates/lease/form", "templates/helper/field/unit", "templates/helper/field/property", "templates/helper/field/tenant", "datepicker"], function($, _, Parse, moment, Property, Unit, Lease, Tenant, Alert, i18nCommon, i18nUnit, i18nLease) {
    var NewLeaseView, _ref;

    return NewLeaseView = (function(_super) {
      __extends(NewLeaseView, _super);

      function NewLeaseView() {
        this.setJulyJune = __bind(this.setJulyJune, this);
        this.setNextMonth = __bind(this.setNextMonth, this);
        this.setThisMonth = __bind(this.setThisMonth, this);
        this.showUnitIfNew = __bind(this.showUnitIfNew, this);
        this.save = __bind(this.save, this);
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        this.render = __bind(this.render, this);        _ref = NewLeaseView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      NewLeaseView.prototype.el = '.content';

      NewLeaseView.prototype.events = {
        'submit form': 'save',
        'click .starting-this-month': 'setThisMonth',
        'click .starting-next-month': 'setNextMonth',
        'click .july-to-june': 'setJulyJune',
        'change .unit-select': 'showUnitIfNew'
      };

      NewLeaseView.prototype.initialize = function(attrs) {
        var _this = this;

        this.property = attrs.property;
        this.unit = attrs.unit;
        this.baseUrl = attrs.baseUrl;
        this.forNetwork = attrs.forNetwork;
        if (!this.model) {
          this.model = new Lease;
        }
        if (this.forNetwork && Parse.User.current() && Parse.User.current().get("network")) {
          this.model.set("network", Parse.User.current().get("network"));
        }
        this.model.set("forNetwork", true);
        this.modal = attrs.modal;
        if (this.modal) {
          this.setElement('#apply-modal');
        }
        this.listenTo(this.model, 'invalid', function(error) {
          var args, fn, msg;

          _this.$('.error').removeClass('error');
          _this.$('button.save').removeProp("disabled");
          console.log(error);
          msg = (function() {
            if (error.message.indexOf(":") > 0) {
              args = error.message.split(":");
              fn = args.pop();
              switch (fn) {
                case "overlapping_dates":
                  return i18nLease.errors[fn]("" + this.baseUrl + "/leases/" + args[0]);
                default:
                  return i18nLease.errors[fn](args[0]);
              }
            } else if (i18nLease.errors[error.message]) {
              return i18nLease.errors[error.message];
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
        this.on("save:success", function(model, isNew) {
          var vars;

          new Alert({
            event: 'model-save',
            fade: true,
            message: i18nCommon.actions.changes_saved,
            type: 'success'
          });
          _this.model.id = model.id;
          if (_this.forNetwork && Parse.User.current()) {
            _this.property.leases.add(_this.model);
            new Parse.Query("Tenant").equalTo("lease", _this.model).include("profile").find().then(function(objs) {
              this.property.tenants.add(objs);
              if (Parse.User.current().get("network")) {
                return Parse.User.current().get("network").tenants.add(objs);
              }
            });
            return require(["views/lease/Show"], function(ShowLeaseView) {
              new ShowLeaseView({
                model: _this.model,
                property: _this.property,
                forNetwork: _this.forNetwork,
                baseUrl: _this.baseUrl
              }).render();
              Parse.history.navigate("" + _this.baseUrl + "/leases/" + model.id);
              return _this.clear();
            });
          } else {
            vars = {
              lease: model,
              unit: model.get("unit"),
              property: model.get("property")
            };
            Parse.User.current().set(vars);
            if (_this.model.isNew()) {
              Parse.history.navigate("/account/building", true);
            } else {
              Parse.history.navigate("/manage", true);
            }
            return _this.clear();
          }
        });
        this.listenTo(this.model, 'destroy', this.clear);
        this.current = new Date().setDate(1);
        return this.dates = {
          start: this.model.get("start_date") ? moment(this.model.get("start_date")).format("L") : moment(this.current).format("L"),
          end: this.model.get("end_date") ? moment(this.model.get("end_date")).format("L") : moment(this.current).add(1, 'year').subtract(1, 'day').format("L")
        };
      };

      NewLeaseView.prototype.render = function() {
        var cancel_path, template, tmpl, vars;

        tmpl = (this.model.isNew() ? 'new' : 'sub/edit') + (this.modal ? "-modal" : "");
        template = "src/js/templates/lease/" + tmpl + ".jst";
        cancel_path = this.baseUrl + (!this.model.isNew() && this.forNetwork ? "/leases/" + this.model.id : "");
        vars = {
          lease: _.defaults(this.model.attributes, Lease.prototype.defaults),
          unit: this.unit ? this.unit.toJSON() : false,
          dates: this.dates,
          cancel_path: cancel_path,
          title: this.property ? this.property.get("title") : false,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          emails: this.model.get("emails") ? this.model.get("emails") : ""
        };
        this.$el.html(JST[template](vars));
        this.$startDate = this.$('.start-date');
        this.$endDate = this.$('.end-date');
        this.$('.datepicker').datepicker();
        if (!this.unit) {
          this.$unitSelect = this.$('.unit-select');
          if (this.property.units.length === 0) {
            this.property.units.fetch();
          } else {
            this.addAll();
          }
        }
        return this;
      };

      NewLeaseView.prototype.addOne = function(u) {
        var HTML;

        HTML = ("<option value='" + u.id + "'") + (this.model.get("unit") && this.model.get("unit").id === u.id ? "selected='selected'" : "") + (">" + (u.get('title')) + "</option>");
        return this.$unitSelect.append(HTML);
      };

      NewLeaseView.prototype.addAll = function() {
        if (this.$unitSelect.children().length > 2) {
          this.$unitSelect.html("<option value=''>" + i18nCommon.form.select.select_value + "</option>\n<option value='-1'>" + i18nUnit.constants.new_unit + "</option>");
        }
        return this.property.units.each(this.addOne);
      };

      NewLeaseView.prototype.save = function(e) {
        var attrs, data, email, unit, userValid, _i, _len, _ref1,
          _this = this;

        e.preventDefault();
        this.$('button.save').prop("disabled", "disabled");
        data = this.$('form').serializeObject();
        this.$('.error').removeClass('error');
        attrs = this.model.scrub(data.lease);
        if (data.unit && data.unit.id !== "") {
          if (this.unit) {
            console.log(this.unit);
            this.unit.set(this.unit.scrub(data.unit.attributes));
            attrs.unit = this.unit;
          } else {
            if (data.unit.id === "-1") {
              unit = new Unit(data.unit.attributes);
              unit.set("property", this.property);
            } else {
              unit = this.property.units.get(data.unit.id);
            }
            attrs.unit = unit;
          }
        }
        userValid = true;
        if (data.emails && data.emails !== '') {
          attrs.emails = [];
          _ref1 = data.emails.split(",");
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            email = _ref1[_i];
            email = $.trim(email);
            userValid = !Parse.User.prototype.validate({
              email: email
            }) ? true : false;
            if (!userValid) {
              break;
            }
            attrs.emails.push(email);
          }
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
          return this.$('.new-unit').show();
        } else {
          return this.$('.new-unit').hide();
        }
      };

      NewLeaseView.prototype.setThisMonth = function(e) {
        e.preventDefault();
        this.$startDate.val(moment(this.current).format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setNextMonth = function(e) {
        e.preventDefault();
        this.$startDate.val(moment(this.current).add(1, 'month').format("L"));
        return this.$endDate.val(moment(this.current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.setJulyJune = function(e) {
        e.preventDefault();
        this.$startDate.val(moment(this.current).month(6).format("L"));
        return this.$endDate.val(moment(this.current).month(6).add(1, 'year').subtract(1, 'day').format("L"));
      };

      NewLeaseView.prototype.clear = function() {
        this.stopListening();
        this.undelegateEvents();
        return delete this;
      };

      return NewLeaseView;

    })(Parse.View);
  });

}).call(this);
