// Generated by CoffeeScript 1.4.0
(function() {

  define(["jquery", "backbone", "views/View"], function($, Backbone, View) {
    var MobileRouter;
    MobileRouter = Backbone.Router.extend({
      initialize: function() {
        return Backbone.history.start();
      },
      routes: {
        "": "index"
      },
      index: function() {
        return new View();
      }
    });
    return MobileRouter;
  });

}).call(this);
