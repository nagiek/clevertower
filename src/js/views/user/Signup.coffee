define [
  "jquery", 
  "underscore", 
  "backbone", 
  'templates/user/signup',
], ($, _, Parse) ->

  class SignupView extends Parse.View
    events:
      "submit form.signup-form": "signUp"

    el: "#signup"
    initialize: ->
      _.bindAll this, "signUp"
      @$parent = $('#registration-menu')
      @$parent.append @el
      @render()
      @$parent.show()

    signUp: (e) ->
      username = @$("#signup-username").val()
      password = @$("#signup-password").val()
      Parse.User.signUp username, password,
        ACL: new Parse.ACL()
      ,
        success: (user) =>
          AppView = require "views/app/Main"
          new AppView()

          this.undelegateEvents();
          this.remove();
          delete this

        error: (user, error) ->
          self.$(".signup-form .error").html(error.message).show()
          @$(".signup-form button").removeAttr "disabled"

      @$(".signup-form button").attr "disabled", "disabled"
      e.preventDefault()

    render: ->
      @$el.html JST["src/js/templates/user/signup.jst"]
      @delegateEvents()
      this