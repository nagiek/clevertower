(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "pusher", 'collections/PropertyList', 'models/Profile', 'views/notification/Index', "i18n!nls/devise", "i18n!nls/user", "i18n!nls/common", "templates/user/logged_in_menu", "templates/user/logged_in_panel"], function($, _, Parse, Pusher, PropertyList, Profile, NotificationsView, i18nDevise, i18nUser, i18nCommon) {
    var LoggedInView, _ref;

    return LoggedInView = (function(_super) {
      __extends(LoggedInView, _super);

      function LoggedInView() {
        this.subscribeProperty = __bind(this.subscribeProperty, this);        _ref = LoggedInView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      LoggedInView.prototype.el = "#user-menu";

      LoggedInView.prototype.events = {
        "click #logout": "logOut"
      };

      LoggedInView.prototype.initialize = function(attrs) {
        this.pusher = new Pusher('dee5c4022be4432d7152');
        if (Parse.User.current().get("network")) {
          this.pusher.subscribe("networks-" + (Parse.User.current().get("network").id));
          this.listenTo(Parse.User.current().get("network").properties, "add", this.subscribeProperty);
        }
        this.listenTo(Parse.User.current().get("profile"), "change:image_profile", this.updatePic);
        this.listenTo(Parse.User.current().get("profile"), "change:first_name change:last_name", this.updateName);
        return this.render();
      };

      LoggedInView.prototype.subscribeProperty = function(obj) {
        return this.pusher.subscribe("properties-" + obj.id);
      };

      LoggedInView.prototype.logOut = function(e) {
        Parse.User.current().save({
          lastLogin: Parse.User.current().updatedAt
        }, {
          patch: true
        });
        Parse.User.logOut();
        Parse.Dispatcher.trigger("user:change");
        Parse.Dispatcher.trigger("user:logout");
        this.undelegateEvents();
        return delete this;
      };

      LoggedInView.prototype.render = function() {
        var name, vars;

        name = Parse.User.current().get("profile").name();
        vars = {
          src: Parse.User.current().get("profile").cover('micro'),
          photo_alt: i18nUser.show.photo(name),
          name: name,
          objectId: Parse.User.current().get("profile").id,
          i18nUser: i18nUser,
          i18nDevise: i18nDevise,
          i18nCommon: i18nCommon
        };
        this.$el.html(JST["src/js/templates/user/logged_in_menu.jst"](vars));
        $("#panel-user-menu").html(JST["src/js/templates/user/logged_in_menu.jst"](vars));
        this.notificationsView = new NotificationsView;
        this.notificationsView.render();
        return this;
      };

      LoggedInView.prototype.updateNav = function() {
        this.$('#profile-link img').prop("src", Parse.User.current().get("profile").cover("micro"));
        return $('#panel-profile-link img').prop("src", Parse.User.current().get("profile").cover("micro"));
      };

      LoggedInView.prototype.updateName = function() {
        this.$('#profile-link span').html(Parse.User.current().get("profile").name());
        return $('#panel-profile-link span').html(Parse.User.current().get("profile").name());
      };

      return LoggedInView;

    })(Parse.View);
  });

}).call(this);
