(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', "i18n!nls/tenant", "i18n!nls/common", 'templates/tenant/summary'], function($, _, Parse, Lease, i18nTenant, i18nCommon) {
    var TenantSummaryView;
    return TenantSummaryView = (function(_super) {

      __extends(TenantSummaryView, _super);

      function TenantSummaryView() {
        return TenantSummaryView.__super__.constructor.apply(this, arguments);
      }

      TenantSummaryView.prototype.tagName = "li";

      TenantSummaryView.prototype.initialize = function() {
        this.user = new Parse.User(this.model.get("user").attributes);
        return this.render();
      };

      TenantSummaryView.prototype.render = function() {
        var vars;
        vars = _.merge(this.user.toJSON(), {
          status: this.model.get('status'),
          url: this.user.cover('thumb'),
          objectId: this.user.id,
          i18nTenant: i18nTenant,
          i18nCommon: i18nCommon
        });
        return JST["src/js/templates/tenant/summary.jst"](vars);
      };

      return TenantSummaryView;

    })(Parse.View);
  });

}).call(this);
