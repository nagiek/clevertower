(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/TodoModel'], function($, _, Parse, Todo) {
    var TodoList;
    return TodoList = (function(_super) {

      __extends(TodoList, _super);

      function TodoList() {
        return TodoList.__super__.constructor.apply(this, arguments);
      }

      TodoList.prototype.model = Todo;

      TodoList.prototype.done = function() {
        return this.filter(function(todo) {
          return todo.get("done");
        });
      };

      TodoList.prototype.remaining = function() {
        return this.without.apply(this, this.done());
      };

      TodoList.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      TodoList.prototype.comparator = function(todo) {
        return todo.get("order");
      };

      return TodoList;

    })(Parse.Collection);
  });

}).call(this);
