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
      text: function() {
        var object;

        object = this.object();
        if (object && this.get("name") === "like") {
          object = i18nCommon.functions.possessive(object);
        }
        if (this.isMemo()) {
          return i18nCommon.notifications[this.get("name")](this.subject(), object);
        } else {
          return i18nCommon.notifications[this.get("name")].invited(this.subject(), object);
        }
      },
      subject: function() {
        if (this.get("subject")) {
          return this.get("subject").name();
        } else {
          return false;
        }
      },
      object: function() {
        if (this.get("name").indexOf("inquiry") !== -1 || this.get("name").indexOf("invitation") !== -1) {
          if (this.get("name").indexOf("network") !== -1) {
            return this.get("network").name();
          } else {
            return this.get("property").get("profile").name();
          }
        } else if (this.get("object")) {
          if (this.get("object").id === Parse.User.current().get("profile").id) {
            return i18nCommon.nouns.you;
          } else {
            return this.get("object").name();
          }
        }
      },
      accepted: function() {
        return i18nCommon.notifications[this.get("name")].accept(this.subject());
      },
      ignored: function() {
        return i18nCommon.notifications[this.get("name")].ignore(this.subject());
      }
    });
  });

}).call(this);
