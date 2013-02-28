define [
  "jquery", 
  "underscore", 
  "backbone", 
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/login',
], ($, _, Parse, i18nDevise, i18nUser) ->

  class LoginView extends Parse.View
    events:
      "submit form.login-form": "logIn"

    el: "#login"
    initialize: ->
      _.bindAll this, "logIn"
      @render()

    logIn: (e) ->
      username = @$("#login-username").val()
      password = @$("#login-password").val()
      Parse.User.logIn username, password,
        success: (user) =>
          AppView = require "views/app/Main"
          new AppView()

          this.undelegateEvents();
          this.remove();
          delete this

        error: (user, error) =>
          this.$(".login-form .error").html(i18nDevise.errors.invalid_login).show()
          @$(".login-form button").removeAttr "disabled"

      @$(".login-form button").attr "disabled", "disabled"
      e.preventDefault()


    render: ->
      @$el.html JST["src/js/templates/user/login.jst"](i18nDevise: i18nDevise, i18nUser: i18nUser)
      @delegateEvents()
      this