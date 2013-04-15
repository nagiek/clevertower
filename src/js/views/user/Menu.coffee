define [
  "jquery"
  "underscore"
  "backbone"
], ($, _, Parse) ->

  class UserMenuView extends Parse.View

    initialize: (attrs) ->
      _.bindAll this, 'render'
      @attrs = attrs
      
    render: ->
      viewName = if Parse.User.current() then "views/user/LoggedIn" else "views/user/LoggedOut"

      # Views clean up after themselves.
      # if @view
      #   @view.undelegateEvents()
      #   delete @view
        
      require [viewName], (UserView) =>
        @view = new UserView(@attrs)
      @