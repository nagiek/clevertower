(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "views/user/LoggedInMenu", "views/user/Login", "views/user/Signup"], function($, _, Parse, LoggedInView, LogInView, SignUpView) {
    var UserMenuView;
    return UserMenuView = (function(_super) {

      __extends(UserMenuView, _super);

      function UserMenuView() {
        return UserMenuView.__super__.constructor.apply(this, arguments);
      }

      UserMenuView.prototype.el = "#user-menu";

      UserMenuView.prototype.initialize = function() {
        return this.render();
      };

      UserMenuView.prototype.render = function() {
        if (Parse.User.current()) {
          return new LoggedInView();
        } else {
          this.$el.html('<li id="login" class="dropdown"></li><li id="signup" class="dropdown"></li>');
          new LogInView();
          return new SignUpView();
        }
      };

      return UserMenuView;

    })(Parse.View);
  });

}).call(this);
