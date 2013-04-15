(function() {

  define(['underscore', 'backbone'], function(_, Parse) {
    var Tenant;
    return Tenant = Parse.Object.extend("Tenant", {
      className: "Tenant",
      defaults: {
        status: "invited"
      }
    });
  });

}).call(this);
