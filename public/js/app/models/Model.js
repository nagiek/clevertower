(function() {

  define(["jquery", "backbone"], function($, Backbone) {
    var Model;
    Model = Backbone.Object.extend("Model", {
      initialize: function() {},
      defaults: {},
      validate: function(attrs) {}
    });
    return Model;
  });

}).call(this);
