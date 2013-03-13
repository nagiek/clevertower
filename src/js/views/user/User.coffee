define [
  "jquery"
  "underscore"
  "backbone"
], ($, _, Parse) ->

  class UserMenuView extends Parse.View    
    el: "#user-menu"

    initialize: ->
      @render()

    render: ->
      console.log 'usermenu'
      if Parse.User.current()
        require ["views/user/LoggedInMenu"], (LoggedInView) ->
          new LoggedInView() 
      else
        # Logged out menu backbone
        @$el.html '<li id="login" class="dropdown"></li><li id="signup" class="dropdown"></li>'
        require ["views/user/Login", "views/user/Signup"], (LogInView, SignUpView) ->
          new LogInView()
          new SignUpView()
