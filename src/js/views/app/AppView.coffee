define [
  "jquery", 
  "underscore", 
  "backbone", 
  'views/todo/ManageTodosView'
  'views/user/LoginView' 
], ($, _, Parse, ManageTodosView, LoginView) ->

  class AppView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: $("#todoapp")
    initialize: ->
      
      @render()

    render: ->
      if Parse.User.current()
        # ManageTodosView = require('views/todo/ManageTodosView')
        new ManageTodosView()
      else
        # LoginView = require('views/user/LoginView')
        new LoginView()