(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', "i18n!nls/tenant", "i18n!nls/common", 'templates/tenant/current'], function($, _, Parse, Lease, i18nTenant, i18nCommon) {
    var TenantSummaryView;
    return TenantSummaryView = (function(_super) {

      __extends(TenantSummaryView, _super);

      function TenantSummaryView() {
        return TenantSummaryView.__super__.constructor.apply(this, arguments);
      }

      TenantSummaryView.prototype.tagName = "li";

      TenantSummaryView.prototype.render = function() {
        var vars;
        vars = _.merge(this.model.toJSON(), {
          i18nTenant: i18nTenant,
          i18nCommon: i18nCommon
        });
        $(this.el).html(JST["src/js/templates/tenant/current.jst"](vars));
        return this;
      };

      return TenantSummaryView;

    })(Parse.View);
  });

}).call(this);
