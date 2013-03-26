define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/devise"
  "templates/user/logged_in_menu"
], ($, _, Parse, i18nDevise) ->

  class LoggedInView extends Parse.View
    events:
      "click #logout": "logOut"

    el: "#user-menu"
    initialize: ->
      _.bindAll this, "logOut"
      @render()

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      Parse.history.navigate "/"
      @trigger "user:change"
      @undelegateEvents();
      delete this

    render: ->
      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](i18nDevise: i18nDevise)
      @delegateEvents()
      @