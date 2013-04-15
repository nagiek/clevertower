(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', 'models/Profile', "i18n!nls/common", "i18n!nls/group", 'templates/profile/summary'], function($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) {
    var TenantSummaryView;
    return TenantSummaryView = (function(_super) {

      __extends(TenantSummaryView, _super);

      function TenantSummaryView() {
        return TenantSummaryView.__super__.constructor.apply(this, arguments);
      }

      TenantSummaryView.prototype.tagName = "li";

      TenantSummaryView.prototype.className = "span";

      TenantSummaryView.prototype.events = {
        'click .delete': 'kill'
      };

      TenantSummaryView.prototype.initialize = function(attrs) {
        var _this = this;
        _.bindAll('this', 'render');
        this.profile = this.model.get("profile");
        return this.model.on("destroy", function() {
          _this.remove();
          _this.undeletegateEvents();
          return delete _this;
        });
      };

      TenantSummaryView.prototype.render = function() {
        var status, vars;
        status = this.model.get('status');
        vars = _.merge(this.profile.toJSON(), {
          i_status: i18nGroup.fields.status[status],
          status: status,
          url: this.profile.cover('thumb'),
          i18nCommon: i18nCommon,
          i18nGroup: i18nGroup
        });
        if (!vars.name) {
          vars.name = this.profile.get("email");
        }
        this.$el.html(JST["src/js/templates/profile/summary.jst"](vars));
        return this;
      };

      TenantSummaryView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm)) {
          return this.model.destroy();
        }
      };

      return TenantSummaryView;

    })(Parse.View);
  });

}).call(this);
