define [
  "jquery", 
  "underscore", 
  "parse", 
  'models/todo/TodoModel',
  'text!templates/todo/item.html',
], ($, _, Parse, Todo, ItemTemplate) ->

  class TodoView extends Parse.View
  
    #... is a list tag.
    tagName: "li"
  
    # Cache the template function for a single item.
    template: _.template(ItemTemplate)
  
    # The DOM events specific to an item.
    events:
      "click .toggle": "toggleDone"
      "dblclick label.todo-content": "edit"
      "click .todo-destroy": "clear"
      "keypress .edit": "updateOnEnter"
      "blur .edit": "close"

  
    # The TodoView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Todo and a TodoView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      _.bindAll this, "render", "close", "remove"
      @model.bind "change", @render
      @model.bind "destroy", @remove

  
    # Re-render the contents of the todo item.
    render: ->
      $(@el).html @template(@model.toJSON())
      @input = @$(".edit")
      this

  
    # Toggle the `"done"` state of the model.
    toggleDone: ->
      @model.toggle()

  
    # Switch this view into `"editing"` mode, displaying the input field.
    edit: ->
      $(@el).addClass "editing"
      @input.focus()

  
    # Close the `"editing"` mode, saving changes to the todo.
    close: ->
      @model.save content: @input.val()
      $(@el).removeClass "editing"

  
    # If you hit `enter`, we're through editing the item.
    updateOnEnter: (e) ->
      @close()  if e.keyCode is 13

  
    # Remove the item, destroy the model.
    clear: ->
      @model.destroy()