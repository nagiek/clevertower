(function() {

  define(["jquery", "backbone", "models/Model"], function($, Backbone, Model) {
    var Collection;
    Collection = Backbone.Collection.extend({
      model: Model
    });
    return Collection;
  });

}).call(this);
