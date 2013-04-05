(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone"], function($, _, Parse) {
    var UserMenuView;
    return UserMenuView = (function(_super) {

      __extends(UserMenuView, _super);

      function UserMenuView() {
        return UserMenuView.__super__.constructor.apply(this, arguments);
      }

      UserMenuView.prototype.initialize = function() {
        _.bindAll(this, 'render');
        return this.render();
      };

      UserMenuView.prototype.render = function() {
        var viewName,
          _this = this;
        viewName = Parse.User.current() ? "views/user/LoggedIn" : "views/user/LoggedOut";
        return require([viewName], function(UserView) {
          var view;
          view = new UserView().render();
          return view.on("user:change", _this.render);
        });
      };

      return UserMenuView;

    })(Parse.View);
  });

}).call(this);
