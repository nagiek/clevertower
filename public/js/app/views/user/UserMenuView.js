(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone"], function($, _, Parse, LoginTemplate) {
    var UserMenuView;
    return UserMenuView = (function(_super) {

      __extends(UserMenuView, _super);

      function UserMenuView() {
        return UserMenuView.__super__.constructor.apply(this, arguments);
      }

      UserMenuView.prototype.events = {
        "click #logout": "logOut"
      };

      UserMenuView.prototype.el = ".content";

      UserMenuView.prototype.initialize = function() {
        _.bindAll(this, "logIn", "signUp");
        return this.render();
      };

      UserMenuView.prototype.logOut = function(e) {
        var LoginView;
        Parse.User.logOut();
        LoginView = require("views/user/LoginView");
        new LoginView();
        this.undelegateEvents();
        return delete this;
      };

      UserMenuView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/menu.jst"]);
        return this.delegateEvents();
      };

      return UserMenuView;

    })(Parse.View);
  });

}).call(this);
