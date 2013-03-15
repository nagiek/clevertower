(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/User"], function($, Parse, UserView) {
    var DesktopRouter;
    return DesktopRouter = (function(_super) {

      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        return DesktopRouter.__super__.constructor.apply(this, arguments);
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "properties/new": "propertiesNew",
        "properties/:id": "propertiesShow",
        "properties/:id/:action": "propertiesShow",
        "*actions": "index"
      };

      DesktopRouter.prototype.initialize = function(options) {
        Parse.history.start({
          pushState: true
        });
        new UserView;
        return $(document).delegate("a", "click", function(e) {
          var href, protocol;
          href = $(this).attr("href");
          if (href === "#" || !(href != null)) {
            return;
          }
          protocol = this.protocol + "//";
          if (href.slice(protocol.length) !== protocol) {
            e.preventDefault();
            return Parse.history.navigate(href, true);
          }
        });
      };

      DesktopRouter.prototype.index = function() {
        var _this = this;
        return require(["views/network/Manage"], function(ManageNetworkView) {
          return new ManageNetworkView;
        });
      };

      DesktopRouter.prototype.propertiesNew = function() {
        var _this = this;
        return require(["views/property/Manage"], function(ManagePropertiesView) {
          var managePropertiesView;
          managePropertiesView = new ManagePropertiesView;
          return managePropertiesView.$el.find('#new-property').click();
        });
      };

      DesktopRouter.prototype.propertiesShow = function(id, action) {
        var _this = this;
        action || (action = 'units');
        return require(["models/Property", "views/property/Show"], function(Property, PropertyView) {
          return new Parse.Query("Property").get(id, {
            success: function(model) {
              $('#main').html('<div id="property"></div>');
              return new PropertyView({
                model: model,
                action: action
              });
            },
            error: function(object, error) {
              return _this.accessDenied();
            }
          });
        });
      };

      DesktopRouter.prototype.accessDenied = function() {
        return require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
          new Alert({
            event: 'access-denied',
            type: 'error',
            fade: true,
            heading: i18nCommon.errors.access_denied,
            message: i18nCommon.errors.no_permission
          });
          return Parse.history.navigate("/");
        });
      };

      return DesktopRouter;

    })(Parse.Router);
  });

}).call(this);
