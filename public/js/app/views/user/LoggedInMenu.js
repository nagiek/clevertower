(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "templates/user/logged_in_menu"], function($, _, Parse) {
    var LoggedInMenuView;
    return LoggedInMenuView = (function(_super) {

      __extends(LoggedInMenuView, _super);

      function LoggedInMenuView() {
        return LoggedInMenuView.__super__.constructor.apply(this, arguments);
      }

      LoggedInMenuView.prototype.events = {
        "click #logout": "logOut"
      };

      LoggedInMenuView.prototype.el = "#user-menu";

      LoggedInMenuView.prototype.initialize = function() {
        _.bindAll(this, "logOut");
        return this.render();
      };

      LoggedInMenuView.prototype.logOut = function(e) {
        var AppView;
        Parse.User.logOut();
        AppView = require("views/app/Main");
        new AppView();
        this.undelegateEvents();
        return delete this;
      };

      LoggedInMenuView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/logged_in_menu.jst"]);
        this.delegateEvents();
        return this;
      };

      return LoggedInMenuView;

    })(Parse.View);
  });

}).call(this);
