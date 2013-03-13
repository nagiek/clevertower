(function() {

  define(['underscore', 'backbone', "models/Property", "models/Unit"], function(_, Parse, Property, Unit) {
    var Photo;
    return Photo = Parse.Object.extend("Photo", {
      defaults: {
        url: "",
        property: "",
        unit: "",
        caption: ""
      }
    });
  });

}).call(this);
