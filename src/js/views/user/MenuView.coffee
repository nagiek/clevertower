define [
  "jquery", 
  "underscore", 
  "backbone", 
  "templates/user/menu",
], ($, _, Parse) ->

  class UserMenuView extends Parse.View
    events:
      "click #logout": "logOut"

    el: ".content"
    initialize: ->
      _.bindAll this, "logOut"
      @render()

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      LoginView = require "views/user/LoginView"
      new LoginView()
      this.undelegateEvents()
      delete this


    render: ->
      @$el.html JST["src/js/templates/user/menu.jst"]
      @delegateEvents()