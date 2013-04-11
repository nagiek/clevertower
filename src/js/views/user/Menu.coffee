define [
  "jquery"
  "underscore"
  "backbone"
], ($, _, Parse) ->

  class UserMenuView extends Parse.View

    initialize: ->
      _.bindAll this, 'render'
      
    render: ->
      viewName = if Parse.User.current() then "views/user/LoggedIn" else "views/user/LoggedOut"
      require [viewName], (UserView) =>
        view = new UserView(model: Parse.User.current())
        view.on "user:change", @render
      @