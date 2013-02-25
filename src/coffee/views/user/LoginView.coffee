define [
  "jquery", 
  "underscore", 
  "parse", 
  'text!templates/user/login.html',
], ($, _, Parse, LoginTemplate) ->

  class LoginView extends Parse.View
    events:
      "submit form.login-form": "logIn"
      "submit form.signup-form": "signUp"

    el: ".content"
    initialize: ->
      _.bindAll this, "logIn", "signUp"
      @render()

    logIn: (e) ->
      username = @$("#login-username").val()
      password = @$("#login-password").val()
      Parse.User.logIn username, password,
        success: (user) =>
          ManageTodosView = require("views/todo/ManageTodosView")          
          new ManageTodosView()
          this.undelegateEvents()
          delete this

        error: (user, error) =>
          this.$(".login-form .error").html("Invalid username or password. Please try again.").show()
          @$(".login-form button").removeAttr "disabled"

      @$(".login-form button").attr "disabled", "disabled"
      false

    signUp: (e) ->
      username = @$("#signup-username").val()
      password = @$("#signup-password").val()
      Parse.User.signUp username, password,
        ACL: new Parse.ACL()
      ,
        success: (user) =>
          new ManageTodosView
          this.undelegateEvents()
          delete this

        error: (user, error) ->
          self.$(".signup-form .error").html(error.message).show()
          @$(".signup-form button").removeAttr "disabled"

      @$(".signup-form button").attr "disabled", "disabled"
      false

    render: ->
      @$el.html _.template(LoginTemplate)
      @delegateEvents()