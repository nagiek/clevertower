(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'collections/tenant/TenantList', 'models/Unit', 'models/Lease', 'models/Tenant', 'views/tenant/Summary', "i18n!nls/unit", "i18n!nls/lease", "i18n!nls/common", 'templates/lease/show'], function($, _, Parse, moment, TenantList, Unit, Lease, Tenant, TenantView, i18nUnit, i18nLease, i18nCommon) {
    var ShowLeaseView;
    return ShowLeaseView = (function(_super) {

      __extends(ShowLeaseView, _super);

      function ShowLeaseView() {
        this.addAll = __bind(this.addAll, this);

        this.addOne = __bind(this.addOne, this);
        return ShowLeaseView.__super__.constructor.apply(this, arguments);
      }

      ShowLeaseView.prototype.el = "#content";

      ShowLeaseView.prototype.initialize = function(attrs) {
        var _this = this;
        this.property = attrs.property;
        this.property.loadUnits();
        return new Parse.Query("Lease").include("unit").get(attrs.subId, {
          success: function(model) {
            _this.model = model;
            _this.render();
            _this.$list = _this.$('ul.tenants');
            _this.tenants = new TenantList([], {
              lease: _this.model
            });
            _this.tenants.on("add", _this.addOne);
            _this.tenants.on("reset", _this.addAll);
            return _this.tenants.fetch();
          }
        });
      };

      ShowLeaseView.prototype.render = function() {
        var modelVars, unitId, vars;
        modelVars = this.model.toJSON();
        unitId = this.model.get("unit").id;
        modelVars.propertyId = this.property.id;
        modelVars.unitId = unitId;
        modelVars.title = this.model.get("unit").get("title");
        modelVars.tenants = false;
        modelVars.start_date = moment(this.model.get("start_date")).format("LL");
        modelVars.end_date = moment(this.model.get("end_date")).format("LL");
        vars = _.merge(modelVars, {
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          i18nCommon: i18nCommon
        });
        $(this.el).html(JST["src/js/templates/lease/show.jst"](vars));
        return this;
      };

      ShowLeaseView.prototype.addOne = function(t) {
        this.$("p.empty").text('');
        return this.$list.append((new TenantView({
          model: t
        })).render());
      };

      ShowLeaseView.prototype.addAll = function() {
        return this.tenants.each(this.addOne);
      };

      return ShowLeaseView;

    })(Parse.View);
  });

}).call(this);
