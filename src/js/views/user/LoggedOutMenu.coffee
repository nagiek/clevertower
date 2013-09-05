define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/logged_out_menu'
  'templates/user/logged_out_panel'
], ($, _, Parse, i18nCommon, i18nDevise, i18nUser) ->

  # This handles the panel as well, which is outside its element.
  class LoggedOutMenuView extends Parse.View

    el: "#user-menu"

    events:
      "click #signup-link" : "showSignupModal"
      "click #login-link"  : "showLoginModal"

    initialize: ->
      @listenTo Parse.Dispatcher, "user:login", @clear

    render: =>
      @$el.html JST["src/js/templates/user/logged_out_menu.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      $("#sidebar-user-menu").html JST["src/js/templates/user/logged_out_panel.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      @

    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this

    showSignupModal: (e) =>
      e.preventDefault()
      $('#signup-modal').modal()
      $("#signup-username").focus()

    showLoginModal: (e) =>
      e.preventDefault()
      $('#login-modal').modal()
      $("#login-username").focus()