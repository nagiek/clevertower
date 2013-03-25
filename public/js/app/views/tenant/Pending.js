(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', "i18n!nls/tenant", "i18n!nls/common", 'templates/tenant/pending'], function($, _, Parse, Lease, i18nTenant, i18nCommon) {
    var PendingTenantView;
    return PendingTenantView = (function(_super) {

      __extends(PendingTenantView, _super);

      function PendingTenantView() {
        return PendingTenantView.__super__.constructor.apply(this, arguments);
      }

      PendingTenantView.prototype.tagName = "li";

      PendingTenantView.prototype.render = function() {
        var vars;
        vars = _.merge(this.model.toJSON(), {
          i18nTenant: i18nTenant,
          i18nCommon: i18nCommon
        });
        $(this.el).html(JST["src/js/templates/tenant/pending.jst"](vars));
        return this;
      };

      return PendingTenantView;

    })(Parse.View);
  });

}).call(this);
