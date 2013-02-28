define [
  "jquery", 
  "underscore", 
  "backbone", 
  "views/property/Manage"
  "views/todo/Manage"
], ($, _, Parse, ManagePropertiesView, ManageTodosView) ->

  class ManageNetworkView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: $("#main")
    
    initialize : ->
      @render()

    render : ->
      if Parse.User.current()
        @user = Parse.User.current()
        # unless @user.get("network")?
        #   new ManageTodosView()
        #   # new ChooseNetworkView()
        # else
        new ManagePropertiesView()
      else
        new ManageTodosView()