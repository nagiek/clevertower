(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "templates/user/menu"], function($, _, Parse) {
    var UserMenuView;
    return UserMenuView = (function(_super) {

      __extends(UserMenuView, _super);

      function UserMenuView() {
        return UserMenuView.__super__.constructor.apply(this, arguments);
      }

      UserMenuView.prototype.events = {
        "click #logout": "logOut"
      };

      UserMenuView.prototype.el = "#user-menu";

      UserMenuView.prototype.initialize = function() {
        _.bindAll(this, "logOut");
        this.parent = $("#primary-nav .nav-collapse");
        return this.render();
      };

      UserMenuView.prototype.logOut = function(e) {
        var AppView, LoginView, SignupView;
        Parse.User.logOut();
        LoginView = require("views/user/Login");
        SignupView = require("views/user/Signup");
        AppView = require("views/app/Main");
        new LoginView();
        new SignupView();
        new AppView();
        this.undelegateEvents();
        this.remove();
        return delete this;
      };

      UserMenuView.prototype.render = function() {
        this.$el.append(JST["src/js/templates/user/menu.jst"]);
        return this.delegateEvents();
      };

      return UserMenuView;

    })(Parse.View);
  });

}).call(this);
