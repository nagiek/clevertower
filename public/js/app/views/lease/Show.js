(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'collections/TenantList', 'models/Unit', 'models/Lease', 'models/Tenant', 'views/tenant/Summary', "i18n!nls/unit", "i18n!nls/lease", "i18n!nls/common", 'templates/lease/show'], function($, _, Parse, moment, TenantList, Unit, Lease, Tenant, TenantView, i18nUnit, i18nLease, i18nCommon) {
    var ShowLeaseView, _ref;

    return ShowLeaseView = (function(_super) {
      __extends(ShowLeaseView, _super);

      function ShowLeaseView() {
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        this.initialize = __bind(this.initialize, this);        _ref = ShowLeaseView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ShowLeaseView.prototype.el = ".content";

      ShowLeaseView.prototype.initialize = function(attrs) {
        this.property = attrs.property;
        this.baseUrl = attrs.baseUrl;
        this.listenTo(this.property.units, "reset", this.updateTitle);
        this.model.prep('tenants');
        this.listenTo(this.model.tenants, "add", this.addOne);
        return this.listenTo(this.model.tenants, "reset", this.addAll);
      };

      ShowLeaseView.prototype.updateTitle = function() {
        var unit;

        unit = this.property.units.get(this.model.get("unit").id);
        if (unit) {
          return this.$("#unit-title").html(unit.get("title"));
        }
      };

      ShowLeaseView.prototype.render = function() {
        var isMgr, title, unit, vars;

        isMgr = Parse.User.current().get("network") && Parse.User.current().get("network").id === this.model.get("network").id;
        unit = this.property.units.get(this.model.get("unit").id) || this.model.get("unit");
        title = unit ? unit.get("title") : "";
        vars = _.merge(this.model.toJSON(), {
          title: title,
          tenants: false,
          isMgr: isMgr,
          start_date: moment(this.model.get("start_date")).format("LL"),
          end_date: moment(this.model.get("end_date")).format("LL"),
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          i18nCommon: i18nCommon,
          baseUrl: this.baseUrl
        });
        this.$el.html(JST["src/js/templates/lease/show.jst"](vars));
        this.$list = this.$('ul#tenants');
        if (this.property.units.length === 0) {
          this.property.units.fetch();
        }
        if (this.model.tenants.length === 0) {
          this.model.tenants.fetch();
        } else {
          this.addAll();
        }
        return this;
      };

      ShowLeaseView.prototype.addOne = function(t) {
        if (t.get("lease").id === this.model.id) {
          this.$("p.empty").text('');
          return this.$list.append((new TenantView({
            model: t
          })).render().el);
        }
      };

      ShowLeaseView.prototype.addAll = function() {
        var _this = this;

        return this.model.tenants.chain().select(function(t) {
          return t.get("lease").id === _this.model.id;
        }).each(this.addOne);
      };

      return ShowLeaseView;

    })(Parse.View);
  });

}).call(this);
