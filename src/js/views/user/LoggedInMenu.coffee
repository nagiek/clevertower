define [
  "jquery", 
  "underscore", 
  "backbone", 
  "templates/user/logged_in_menu",
], ($, _, Parse) ->

  class LoggedInMenuView extends Parse.View
    events:
      "click #logout": "logOut"

    el: "#user-menu"
    initialize: ->
      _.bindAll this, "logOut"
      @render()

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      AppView = require "views/app/Main"
      new AppView()
      
      this.undelegateEvents();
      delete this

    render: ->
      @$el.html JST["src/js/templates/user/logged_in_menu.jst"]
      @delegateEvents()
      this