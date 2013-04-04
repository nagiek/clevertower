(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "pusher", 'collections/property/PropertyList', 'views/notification/Index', "i18n!nls/devise", "i18n!nls/user", "templates/user/logged_in_menu"], function($, _, Parse, Pusher, PropertyList, NotificationsView, i18nDevise, i18nUser) {
    var LoggedInView;
    return LoggedInView = (function(_super) {

      __extends(LoggedInView, _super);

      function LoggedInView() {
        this.subscribeLease = __bind(this.subscribeLease, this);

        this.subscribeProperty = __bind(this.subscribeProperty, this);
        return LoggedInView.__super__.constructor.apply(this, arguments);
      }

      LoggedInView.prototype.events = {
        "click #logout": "logOut"
      };

      LoggedInView.prototype.el = "#user-menu";

      LoggedInView.prototype.initialize = function() {
        _.bindAll(this, "logOut");
        this.$el.html(JST["src/js/templates/user/logged_in_menu.jst"]({
          i18nUser: i18nUser,
          i18nDevise: i18nDevise
        }));
        Parse.User.current().on("change:type", this.render);
        this.pusher = new Pusher('dee5c4022be4432d7152');
        this.properties = new PropertyList;
        this.properties.on("add", this.subscribeProperty);
        this.notificationsView = new NotificationsView;
        return this.render();
      };

      LoggedInView.prototype.subscribeProperty = function(e) {
        return this.pusher.subscribe("property-" + obj.id);
      };

      LoggedInView.prototype.subscribeLease = function(e) {
        return this.pusher.subscribe("lease-" + obj.id);
      };

      LoggedInView.prototype.logOut = function(e) {
        Parse.User.logOut();
        Parse.history.navigate("/");
        this.trigger("user:change");
        this.undelegateEvents();
        return delete this;
      };

      LoggedInView.prototype.render = function() {
        var _this = this;
        this.notificationsView.render();
        if (Parse.User.current().get("type") === "manager") {
          require(["views/property/Manage"], function(ManagePropertiesView) {
            _this.subview = new ManagePropertiesView({
              collection: _this.properties
            });
            return _this.subview.render();
          });
        } else {
          require(["views/property/Manage"], function(ManagePropertiesView) {
            _this.subview = new ManagePropertiesView({
              collection: _this.properties
            });
            return _this.subview.render();
          });
        }
        return this;
      };

      return LoggedInView;

    })(Parse.View);
  });

}).call(this);
