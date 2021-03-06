(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/User"], function($, Parse, UserView) {
    var DesktopRouter, _ref;

    return DesktopRouter = (function(_super) {
      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        _ref = DesktopRouter.__super__.constructor.apply(this, arguments);
        return _ref;
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
        return new UserView;
      };

      DesktopRouter.prototype.index = function() {
        return new AppView();
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
          $('#main').html('<div id="property"></div>');
          return new Parse.Query("Property").get(id, {
            success: function(model) {
              return new PropertyView({
                model: model,
                action: action
              });
            }
          });
        });
      };

      return DesktopRouter;

    })(Parse.Router);
  });

}).call(this);
