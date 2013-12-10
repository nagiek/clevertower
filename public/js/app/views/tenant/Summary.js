(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', 'models/Profile', "i18n!nls/common", "i18n!nls/group", 'templates/tenant/summary'], function($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) {
    var TenantSummaryView, _ref;

    return TenantSummaryView = (function(_super) {
      __extends(TenantSummaryView, _super);

      function TenantSummaryView() {
        this.clear = __bind(this.clear, this);        _ref = TenantSummaryView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      TenantSummaryView.prototype.tagName = "li";

      TenantSummaryView.prototype.className = "col-sm-6 col-md-4";

      TenantSummaryView.prototype.events = {
        'click .delete': 'kill'
      };

      TenantSummaryView.prototype.initialize = function(attrs) {
        this.showProperty = attrs.showProperty;
        this.showUnit = attrs.showUnit;
        this.listenTo(this.model, "destroy", this.clear);
        if (this.showUnit && Parse.User.current()) {
          if (Parse.User.current().get("network")) {
            return this.listenTo(Parse.User.current().get("network").units, "reset", this.addUnit);
          } else if (Parse.User.current().get("property")) {
            return this.listenTo(Parse.User.current().get("property").units, "reset", this.addUnit);
          }
        }
      };

      TenantSummaryView.prototype.render = function() {
        var property, status, unit, vars,
          _this = this;

        status = this.model.get('status');
        vars = _.merge(this.model.get("profile").toJSON(), {
          i_status: i18nGroup.fields.status[status],
          status: status,
          name: this.model.get("profile").name(),
          url: this.model.get("profile").cover('thumb'),
          i18nCommon: i18nCommon,
          i18nGroup: i18nGroup,
          property: false,
          unit: false
        });
        if (Parse.User.current() && (this.showProperty || this.showUnit)) {
          if (Parse.User.current().get("network")) {
            if (this.showProperty) {
              property = Parse.User.current().get("network").properties.find(function(p) {
                return p.id === _this.model.get("property").id;
              });
              if (property) {
                vars.property = property.get("title");
              }
            }
            if (this.showUnit) {
              unit = Parse.User.current().get("network").units.find(function(u) {
                return u.id === _this.model.get("unit").id;
              });
              if (unit) {
                vars.unit = unit.get("title");
              }
            }
          }
          if (Parse.User.current().get("property")) {
            if (this.showProperty && Parse.User.current().get("property") && Parse.User.current().get("property").id === this.model.get("property").id) {
              vars.property = Parse.User.current().get("property").get("title");
            }
            if (this.showUnit) {
              unit = Parse.User.current().get("property").units.find(function(u) {
                return u.id === _this.model.get("unit").id;
              });
              if (unit) {
                vars.unit = unit.get("title");
              }
            }
          }
        }
        this.$el.html(JST["src/js/templates/tenant/summary.jst"](vars));
        return this;
      };

      TenantSummaryView.prototype.addUnit = function() {
        var unit,
          _this = this;

        if (Parse.User.current()) {
          if (Parse.User.current().get("network")) {
            unit = Parse.User.current().get("network").units.find(function(u) {
              return u.id === _this.model.get("unit").id;
            });
          } else if (Parse.User.current().get("property")) {
            unit = Parse.User.current().get("property").units.find(function(u) {
              return u.id === _this.model.get("unit").id;
            });
          }
          if (unit) {
            return this.$(".unit").html(unit.get("title"));
          }
        }
      };

      TenantSummaryView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm)) {
          return this.model.destroy();
        }
      };

      TenantSummaryView.prototype.clear = function() {
        this.remove();
        this.undelegateEvents();
        return delete this;
      };

      return TenantSummaryView;

    })(Parse.View);
  });

}).call(this);
