(function() {

  define(['underscore', 'backbone'], function(_, Parse) {
    var Todo;
    return Todo = Parse.Object.extend("Todo", {
      defaults: {
        content: "empty todo...",
        done: false
      },
      initialize: function() {
        if (!this.get("content")) {
          return this.set({
            content: this.defaults.content
          });
        }
      },
      toggle: function() {
        return this.save({
          done: !this.get("done")
        });
      },
      validate: function(attrs) {}
    });
  });

}).call(this);
