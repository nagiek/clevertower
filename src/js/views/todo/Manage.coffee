define [
  "jquery", 
  "underscore", 
  "backbone", 
  'collections/todo/TodoList',
  'models/AppState',
  'models/Todo',
  'views/todo/Todo',
  'templates/todo/stats',
  'templates/todo/manage',
], ($, _, Parse, TodoList, AppState, Todo, TodoView, StatsTemplate, ManageTemplate) ->

  class ManageTodosView extends Parse.View
  
    # Our template for the line of statistics at the bottom of the app.
    statsTemplate: JST["src/js/templates/todo/stats.jst"]
  
    # Delegated events for creating new items, and clearing completed ones.
    events:
      "keypress #new-todo": "createOnEnter"
      "click #clear-completed": "clearCompleted"
      "click #toggle-all": "toggleAllComplete"
      "click ul#filters a": "selectFilter"

    el: ".content"
  
    # At initialization we bind to the relevant events on the `Todos`
    # collection, when items are added or changed. Kick things off by
    # loading any preexisting todos that might be saved to Parse.
    initialize: ->
      self = this
      
      @state = new AppState
      @state.set filter: "all"
      
      _.bindAll this, "addOne", "addAll", "addSome", "render", "toggleAllComplete", "createOnEnter"
    
      # Main todo management template
      @$el.html JST["src/js/templates/todo/manage.jst"]
      # @$el.html _.template(ManageTemplate)
      @input = @$("#new-todo")
      @allCheckbox = @$("#toggle-all")[0]
    
      # Create our collection of Todos
      @todos = new TodoList
    
      # Setup the query for the collection to look for todos from the current user
      @todos.query = new Parse.Query(Todo)
      @todos.query.equalTo "user", Parse.User.current()
      @todos.bind "add", @addOne
      @todos.bind "reset", @addAll
      @todos.bind "all", @render
    
      # Fetch all the todo items for this user
      @todos.fetch()
      @state.on "change", @filter, this
  
    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: ->
      done = @todos.done().length
      remaining = @todos.remaining().length
      @$("#todo-stats").html @statsTemplate(
        total: @todos.length
        done: done
        remaining: remaining
      )
      @delegateEvents()
      @allCheckbox.checked = not remaining

  
    # Filters the list based on which type of filter is selected
    selectFilter: (e) ->
      el = $(e.target)
      filterValue = el.attr("id")
      @state.set filter: filterValue

    filter: ->
      filterValue = @state.get("filter")
      @$("ul#filters a").removeClass "selected"
      @$("ul#filters a#" + filterValue).addClass "selected"
      if filterValue is "all"
        @addAll()
      else if filterValue is "completed"
        @addSome (item) ->
          item.get "done"

      else
        @addSome (item) ->
          not item.get("done")


  
    # Resets the filters to display all todos
    resetFilters: ->
      @$("ul#filters a").removeClass "selected"
      @$("ul#filters a#all").addClass "selected"
      @addAll()

  
    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$("#todo-list").append view.render().el

  
    # Add all items in the Todos collection at once.
    addAll: (collection, filter) ->
      @$("#todo-list").html ""
      @todos.each @addOne

  
    # Only adds some todos, based on a filtering function that is passed in
    addSome: (filter) ->
      self = this
      @$("#todo-list").html ""
      @todos.chain().filter(filter).each (item) ->
        self.addOne item


  
    # If you hit return in the main input field, create new Todo model
    createOnEnter: (e) ->
      self = this
      return  unless e.keyCode is 13
      @todos.create
        content: @input.val()
        order: @todos.nextOrder()
        done: false
        user: Parse.User.current()
        ACL: new Parse.ACL(Parse.User.current())

      @input.val ""
      @resetFilters()

  
    # Clear all done todo items, destroying their models.
    clearCompleted: ->
      _.each @todos.done(), (todo) ->
        todo.destroy()

      false

    toggleAllComplete: ->
      done = @allCheckbox.checked
      @todos.each (todo) ->
        todo.save done: done