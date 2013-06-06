define [
  "jquery"
  "underscore"
  "backbone"
], ($, _, Parse) ->

  class UserMenuView extends Parse.View
      
    render: ->
      if Parse.User.current() then require ["views/user/LoggedIn"], (LoggedInView) => new LoggedInView().render()
      else require ["views/user/LoggedOutMenu", "views/user/LoggedOutModals"], (LoggedOutMenuView, LoggedOutModalsView) => 
        new LoggedOutMenuView().render()
        new LoggedOutModalsView().render()
      @