(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Notification', 'models/Property'], function($, _, Parse, Notification, Property) {
    var NotificationList;
    return NotificationList = (function(_super) {

      __extends(NotificationList, _super);

      function NotificationList() {
        return NotificationList.__super__.constructor.apply(this, arguments);
      }

      NotificationList.prototype.model = Notification;

      NotificationList.prototype.query = new Parse.Query("Notification").include('property').include('user').limit(10);

      NotificationList.prototype.unread = function() {
        return this.filter(function(notification) {
          if (notification.get("read")) {
            return false;
          } else {
            return true;
          }
        });
      };

      return NotificationList;

    })(Parse.Collection);
  });

}).call(this);
