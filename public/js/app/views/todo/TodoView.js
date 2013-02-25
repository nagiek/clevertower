(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/TodoModel', 'templates/todo/item'], function($, _, Parse, Todo) {
    var TodoView;
    return TodoView = (function(_super) {

      __extends(TodoView, _super);

      function TodoView() {
        return TodoView.__super__.constructor.apply(this, arguments);
      }

      TodoView.prototype.tagName = "li";

      TodoView.prototype.template = JST["src/js/templates/todo/item.jst"];

      TodoView.prototype.events = {
        "click .toggle": "toggleDone",
        "dblclick label.todo-content": "edit",
        "click .todo-destroy": "clear",
        "keypress .edit": "updateOnEnter",
        "blur .edit": "close"
      };

      TodoView.prototype.initialize = function() {
        _.bindAll(this, "render", "close", "remove");
        this.model.bind("change", this.render);
        return this.model.bind("destroy", this.remove);
      };

      TodoView.prototype.render = function() {
        $(this.el).html(this.template(this.model.toJSON()));
        this.input = this.$(".edit");
        return this;
      };

      TodoView.prototype.toggleDone = function() {
        return this.model.toggle();
      };

      TodoView.prototype.edit = function() {
        $(this.el).addClass("editing");
        return this.input.focus();
      };

      TodoView.prototype.close = function() {
        this.model.save({
          content: this.input.val()
        });
        return $(this.el).removeClass("editing");
      };

      TodoView.prototype.updateOnEnter = function(e) {
        if (e.keyCode === 13) {
          return this.close();
        }
      };

      TodoView.prototype.clear = function() {
        return this.model.destroy();
      };

      return TodoView;

    })(Parse.View);
  });

}).call(this);
