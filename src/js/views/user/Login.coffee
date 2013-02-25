define [
  "jquery", 
  "underscore", 
  "backbone", 
  'templates/user/login',
], ($, _, Parse) ->

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
          this.$(".login-form .error").html("Invalid email or password. Please try again.").show()
          @$(".login-form button").removeAttr "disabled"

      @$(".login-form button").attr "disabled", "disabled"
      e.preventDefault()


    render: ->
      @$el.html JST["src/js/templates/user/login.jst"]
      @delegateEvents()
      this