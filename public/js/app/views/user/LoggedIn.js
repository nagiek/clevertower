(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "pusher", 'collections/property/PropertyList', 'models/Profile', 'views/notification/Index', "i18n!nls/devise", "i18n!nls/user", "templates/user/logged_in_menu"], function($, _, Parse, Pusher, PropertyList, Profile, NotificationsView, i18nDevise, i18nUser) {
    var LoggedInView;
    return LoggedInView = (function(_super) {

      __extends(LoggedInView, _super);

      function LoggedInView() {
        this.subscribeProperty = __bind(this.subscribeProperty, this);
        return LoggedInView.__super__.constructor.apply(this, arguments);
      }

      LoggedInView.prototype.events = {
        "click #logout": "logOut"
      };

      LoggedInView.prototype.el = "#user-menu";

      LoggedInView.prototype.initialize = function() {
        var _this = this;
        _.bindAll(this, "render", "changeName", "logOut");
        this.pusher = new Pusher('dee5c4022be4432d7152');
        if (!Parse.User.current().properties) {
          Parse.User.current().properties = new PropertyList;
        }
        Parse.User.current().properties.on("add", this.subscribeProperty);
        if (Parse.User.current().profile) {
          Parse.User.current().profile.on("sync", this.changeName);
          return this.render();
        } else {
          return (new Parse.Query(Profile)).equalTo("user", Parse.User.current()).first().then(function(profile) {
            Parse.User.current().profile = profile;
            Parse.User.current().profile.on("sync", _this.changeName);
            return _this.render();
          });
        }
      };

      LoggedInView.prototype.subscribeProperty = function(obj) {
        return this.pusher.subscribe("property-" + obj.id);
      };

      LoggedInView.prototype.logOut = function(e) {
        Parse.User.logOut();
        Parse.history.navigate("/");
        this.trigger("user:change");
        this.trigger("user:logout");
        this.undelegateEvents();
        return delete this;
      };

      LoggedInView.prototype.render = function() {
        var vars;
        vars = _.merge({
          objectId: Parse.User.current().profile.id,
          i18nUser: i18nUser,
          i18nDevise: i18nDevise
        });
        this.$el.html(JST["src/js/templates/user/logged_in_menu.jst"](vars));
        this.changeName(Parse.User.current().profile);
        this.notificationsView = new NotificationsView;
        this.notificationsView.render();
        return this;
      };

      LoggedInView.prototype.changeName = function(model) {
        var name;
        if (model) {
          name = model.get("name");
        }
        if (name == null) {
          name = Parse.User.current().getUsername();
        }
        return this.$('#profile-link').html(name);
      };

      return LoggedInView;

    })(Parse.View);
  });

}).call(this);
