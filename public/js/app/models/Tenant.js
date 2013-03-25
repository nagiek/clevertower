(function() {

  define(['underscore', 'backbone', 'models/Lease'], function(_, Parse) {
    var Tenant;
    return Tenant = Parse.Object.extend("Tenant", {
      defaults: {
        status: "invited"
      }
    });
  });

}).call(this);
