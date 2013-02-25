define [
  'underscore',
  'backbone',
], (_, Parse) ->

  Todo = Parse.Object.extend "Todo",
  
    # Default attributes for the todo.
    defaults:
      content: "empty todo..."
      done: false

  
    # Ensure that each todo created has `content`.
    initialize: ->
      @set content: @defaults.content  unless @get("content")

  
    # Toggle the `done` state of this todo item.
    toggle: ->
      @save done: not @get("done")
      
    # Gets called automatically by Backbone when the set and/or save methods are called (Add your own logic)
    validate: (attrs) ->