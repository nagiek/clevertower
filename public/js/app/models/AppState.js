(function() {

  define(['underscore', 'backbone'], function(_, Parse) {
    var AppState;
    return AppState = Parse.Object.extend("AppState", {
      defaults: {
        filter: "all"
      }
    });
  });

}).call(this);
