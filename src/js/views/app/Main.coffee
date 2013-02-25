define [
  "jquery", 
  "underscore", 
  "backbone", 
  'views/todo/ManageTodos'
  "views/user/User"
], ($, _, Parse, ManageTodosView, UserView) ->

  class AppView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: $("#main")
    initialize: ->
      @render()

    render: ->
      new UserView()
      new ManageTodosView()
      