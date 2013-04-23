(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/TodoList', 'models/AppState', 'models/Todo', 'views/todo/Todo', 'templates/todo/stats', 'templates/todo/manage'], function($, _, Parse, TodoList, AppState, Todo, TodoView, StatsTemplate, ManageTemplate) {
    var ManageTodosView;
    return ManageTodosView = (function(_super) {

      __extends(ManageTodosView, _super);

      function ManageTodosView() {
        return ManageTodosView.__super__.constructor.apply(this, arguments);
      }

      ManageTodosView.prototype.statsTemplate = JST["src/js/templates/todo/stats.jst"];

      ManageTodosView.prototype.events = {
        "keypress #new-todo": "createOnEnter",
        "click #clear-completed": "clearCompleted",
        "click #toggle-all": "toggleAllComplete",
        "click ul#filters a": "selectFilter"
      };

      ManageTodosView.prototype.el = "#main";

      ManageTodosView.prototype.initialize = function() {
        var self;
        self = this;
        this.state = new AppState;
        this.state.set({
          filter: "all"
        });
        _.bindAll(this, "addOne", "addAll", "addSome", "render", "toggleAllComplete", "createOnEnter");
        this.$el.html(JST["src/js/templates/todo/manage.jst"]);
        this.input = this.$("#new-todo");
        this.allCheckbox = this.$("#toggle-all")[0];
        this.todos = new TodoList;
        this.todos.query = new Parse.Query(Todo);
        this.todos.query.equalTo("user", Parse.User.current());
        this.todos.bind("add", this.addOne);
        this.todos.bind("reset", this.addAll);
        this.todos.bind("all", this.render);
        this.todos.fetch();
        return this.state.on("change", this.filter, this);
      };

      ManageTodosView.prototype.render = function() {
        var done, remaining;
        done = this.todos.done().length;
        remaining = this.todos.remaining().length;
        this.$("#todo-stats").html(this.statsTemplate({
          total: this.todos.length,
          done: done,
          remaining: remaining
        }));
        this.delegateEvents();
        return this.allCheckbox.checked = !remaining;
      };

      ManageTodosView.prototype.selectFilter = function(e) {
        var el, filterValue;
        el = $(e.target);
        filterValue = el.attr("id");
        return this.state.set({
          filter: filterValue
        });
      };

      ManageTodosView.prototype.filter = function() {
        var filterValue;
        filterValue = this.state.get("filter");
        this.$("ul#filters a").removeClass("selected");
        this.$("ul#filters a#" + filterValue).addClass("selected");
        if (filterValue === "all") {
          return this.addAll();
        } else if (filterValue === "completed") {
          return this.addSome(function(item) {
            return item.get("done");
          });
        } else {
          return this.addSome(function(item) {
            return !item.get("done");
          });
        }
      };

      ManageTodosView.prototype.resetFilters = function() {
        this.$("ul#filters a").removeClass("selected");
        this.$("ul#filters a#all").addClass("selected");
        return this.addAll();
      };

      ManageTodosView.prototype.addOne = function(todo) {
        var view;
        view = new TodoView({
          model: todo
        });
        return this.$("#todo-list").append(view.render().el);
      };

      ManageTodosView.prototype.addAll = function(collection, filter) {
        this.$("#todo-list").html("");
        return this.todos.each(this.addOne);
      };

      ManageTodosView.prototype.addSome = function(filter) {
        var self;
        self = this;
        this.$("#todo-list").html("");
        return this.todos.chain().filter(filter).each(function(item) {
          return self.addOne(item);
        });
      };

      ManageTodosView.prototype.createOnEnter = function(e) {
        var self;
        self = this;
        if (e.keyCode !== 13) {
          return;
        }
        this.todos.create({
          content: this.input.val(),
          order: this.todos.nextOrder(),
          done: false,
          user: Parse.User.current(),
          ACL: new Parse.ACL(Parse.User.current())
        });
        this.input.val("");
        return this.resetFilters();
      };

      ManageTodosView.prototype.clearCompleted = function() {
        _.each(this.todos.done(), function(todo) {
          return todo.destroy();
        });
        return false;
      };

      ManageTodosView.prototype.toggleAllComplete = function() {
        var done;
        done = this.allCheckbox.checked;
        return this.todos.each(function(todo) {
          return todo.save({
            done: done
          });
        });
      };

      return ManageTodosView;

    })(Parse.View);
  });

}).call(this);
