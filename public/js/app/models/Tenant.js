(function() {

  define(['underscore', 'backbone', "models/Lease"], function(_, Parse, Lease) {
    var Tenant;
    return Tenant = Parse.Object.extend("Tenant");
  });

}).call(this);
