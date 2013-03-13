(function() {

  define(['underscore', 'backbone', "models/Property", "models/Unit"], function(_, Parse, Property, Unit) {
    var Lease;
    return Lease = Parse.Object.extend("Lease");
  });

}).call(this);
