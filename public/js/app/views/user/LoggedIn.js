(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "i18n!nls/devise", "templates/user/logged_in_menu"], function($, _, Parse, i18nDevise) {
    var LoggedInView;
    return LoggedInView = (function(_super) {

      __extends(LoggedInView, _super);

      function LoggedInView() {
        return LoggedInView.__super__.constructor.apply(this, arguments);
      }

      LoggedInView.prototype.events = {
        "click #logout": "logOut"
      };

      LoggedInView.prototype.el = "#user-menu";

      LoggedInView.prototype.initialize = function() {
        _.bindAll(this, "logOut");
        return this.render();
      };

      LoggedInView.prototype.logOut = function(e) {
        Parse.User.logOut();
        Parse.history.navigate("/");
        this.trigger("user:change");
        this.undelegateEvents();
        return delete this;
      };

      LoggedInView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/logged_in_menu.jst"]({
          i18nDevise: i18nDevise
        }));
        this.delegateEvents();
        return this;
      };

      return LoggedInView;

    })(Parse.View);
  });

}).call(this);
