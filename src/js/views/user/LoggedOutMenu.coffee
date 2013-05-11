define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/logged_out_menu'
], ($, _, Parse, i18nCommon, i18nDevise, i18nUser) ->

  class LoggedOutMenuView extends Parse.View

    el: "#user-menu"

    events:
      "click #signup-link" : "showSignupModal"
      "click #login-link"  : "showLoginModal"

    initialize: ->
      Parse.Dispatcher.on "user:login", (user) =>
        @undelegateEvents()
        delete this

    render: =>
      @$el.html JST["src/js/templates/user/logged_out_menu.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      @

    showSignupModal: (e) =>
      e.preventDefault()
      $('#signup-modal').modal()

    showLoginModal: (e) =>
      e.preventDefault()
      $('#login-modal').modal()