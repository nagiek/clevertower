(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Lease', 'models/Profile', "i18n!nls/common", "i18n!nls/group", 'templates/profile/summary'], function($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) {
    var TenantSummaryView, _ref;

    return TenantSummaryView = (function(_super) {
      __extends(TenantSummaryView, _super);

      function TenantSummaryView() {
        this.clear = __bind(this.clear, this);        _ref = TenantSummaryView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      TenantSummaryView.prototype.tagName = "li";

      TenantSummaryView.prototype.className = "span";

      TenantSummaryView.prototype.events = {
        'click .delete': 'kill'
      };

      TenantSummaryView.prototype.initialize = function(attrs) {
        return this.listenTo(this.model, "destroy", this.clear);
      };

      TenantSummaryView.prototype.render = function() {
        var status, vars;

        status = this.model.get('status');
        vars = _.merge(this.model.get("profile").toJSON(), {
          i_status: i18nGroup.fields.status[status],
          status: status,
          name: this.model.get("profile").name(),
          url: this.model.get("profile").cover('thumb'),
          i18nCommon: i18nCommon,
          i18nGroup: i18nGroup
        });
        this.$el.html(JST["src/js/templates/profile/summary.jst"](vars));
        return this;
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
