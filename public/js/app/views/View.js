(function() {

  define(["jquery", "backbone", "models/Model", "text!templates/heading.html"], function($, Backbone, Model, template) {
    var View;
    View = Backbone.View.extend({
      el: ".example",
      initialize: function() {
        return this.render();
      },
      events: {},
      render: function() {
        this.template = _.template(template, {});
        this.$el.html(this.template);
        return this;
      }
    });
    return View;
  });

}).call(this);
