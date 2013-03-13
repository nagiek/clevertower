(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/app/Main", "views/address/Map"], function($, Parse, AppView, NewAddressView) {
    var MobileRouter;
    return MobileRouter = (function(_super) {

      __extends(MobileRouter, _super);

      function MobileRouter() {
        return MobileRouter.__super__.constructor.apply(this, arguments);
      }

      MobileRouter.prototype.routes = {
        "": "index",
        "properties/new": "propertiesNew",
        "properties/:id": "propertiesShow",
        "properties/:id/:action": "propertiesShow",
        "*actions": "index"
      };

      MobileRouter.prototype.initialize = function(options) {
        return Parse.history.start({
          pushState: true
        });
      };

      MobileRouter.prototype.index = function() {
        return new AppView();
      };

      MobileRouter.prototype.propertiesNew = function() {
        var _this = this;
        return require(["views/property/Manage"], function(ManagePropertiesView) {
          var managePropertiesView;
          managePropertiesView = new ManagePropertiesView;
          return managePropertiesView.$el.find('#new-property').click();
        });
      };

      MobileRouter.prototype.propertiesShow = function(id, action) {
        var _this = this;
        action || (action = 'current');
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

      return MobileRouter;

    })(Parse.Router);
  });

}).call(this);
