define [
  "jquery"
  "underscore"
  "backbone"
  "views/network/Manage"
], ($, _, Parse, UserView, ManageNetworkView) ->

  class AppView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: $("#main")
    initialize: ->
      @render()

    render: ->
      new ManageNetworkView()
    
      