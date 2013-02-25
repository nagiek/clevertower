(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/app/AppView"], function($, Parse, AppView) {
    var AppRouter;
    return AppRouter = (function(_super) {

      __extends(AppRouter, _super);

      function AppRouter() {
        return AppRouter.__super__.constructor.apply(this, arguments);
      }

      AppRouter.prototype.routes = {
        "": "index"
      };

      AppRouter.prototype.initialize = function(options) {
        return Parse.history.start();
      };

      AppRouter.prototype.index = function() {
        return new AppView();
      };

      return AppRouter;

    })(Parse.Router);
  });

}).call(this);
