(function() {

  define(['underscore', 'backbone'], function(_, Parse) {
    var Notification;
    return Notification = Parse.Object.extend("Notification", {
      defaults: {
        read: false
      }
    });
  });

}).call(this);
