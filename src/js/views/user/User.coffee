define [
  "jquery", 
  "underscore", 
  "backbone", 
  "views/user/LoggedInMenu",
  "views/user/Login",
  "views/user/Signup",
], ($, _, Parse, LoggedInView, LogInView, SignUpView) ->

  class UserMenuView extends Parse.View    
    el: "#user-menu"
    initialize: ->
      @render()

    render: ->
      if Parse.User.current()
        new LoggedInView();
      else
        @$el.html '<li id="login" class="dropdown"></li><li id="signup" class="dropdown"></li>'
        new LogInView();
        new SignUpView();
