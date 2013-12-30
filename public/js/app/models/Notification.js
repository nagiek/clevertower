(function() {
  define(['underscore', 'backbone', 'models/Profile', "i18n!nls/common"], function(_, Parse, Profile, i18nCommon) {
    var Notification;

    return Notification = Parse.Object.extend("Notification", {
      className: "Notification",
      defaults: {
        read: [],
        clicked: []
      },
      unread: function() {
        if (this.get("read") && _.contains(this.get("read"), Parse.User.current().id)) {
          return false;
        } else {
          return true;
        }
      },
      unclicked: function() {
        if (this.get("clicked") && _.contains(this.get("clicked"), Parse.User.current().id)) {
          return false;
        } else {
          return true;
        }
      },
      hidden: function() {
        if (this.get("hidden") && _.contains(this.get("hidden"), Parse.User.current().id)) {
          return true;
        } else {
          return false;
        }
      },
      isMemo: function() {
        if (this.get("withAction")) {
          return false;
        } else {
          return true;
        }
      },
      withAction: function() {
        if (this.get("withAction")) {
          return true;
        } else {
          return false;
        }
      },
      title: function() {
        if (this.get("property")) {
          return this.get("property").get("profile").name();
        } else {
          return this.get("network").get("title");
        }
      },
      text: function() {
        if (this.isMemo()) {
          return i18nCommon.notifications[this.get("name")](this.name(), this.title());
        } else {
          return i18nCommon.notifications[this.get("name")].invited(this.name(), this.title());
        }
      },
      name: function() {
        if (this.get("profile")) {
          return this.get("profile").name();
        } else {
          return false;
        }
      },
      accepted: function() {
        return i18nCommon.notifications[this.get("name")].accept(this.title());
      },
      ignored: function() {
        return i18nCommon.notifications[this.get("name")].ignore(this.title());
      }
    });
  });

}).call(this);
