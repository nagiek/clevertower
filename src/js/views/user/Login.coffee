define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/login'
], ($, _, Parse, NotificationList, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class LoginView extends Parse.View

    el: "#main"

    events:
      "submit form#login-form"        : "logIn"
      "click .btn-facebook"            : "logInWithFacebook"

    render: =>
      @$el.html JST["src/js/templates/user/login.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      
      @

    logIn: (e) =>
      e.preventDefault()
      @$("> #login #login-form button").prop "disabled", "disabled"
      email = @$("#login-username").val()
      password = @$("#login-password").val()
      Parse.User.logIn email, password,
        success: (user) =>
          @$('> #login').modal('hide')
          Parse.Dispatcher.trigger "user:loginStart", user

        error: (user, error) =>
          @$("> #login #login-form button").removeProp "disabled"
          @$('> #login #login-form .username-group').addClass('error')
          @$('> #login #login-form .password-group').addClass('error')

          msg = switch error.code
            when -1   then i18nDevise.errors.fields_missing
            else i18nDevise.errors.invalid_login
          
          @$("> #login #login-form .alert-error").html(msg).show()

    logInWithFacebook : (e) =>  
      e.preventDefault()
      Parse.FacebookUtils.logIn "user_likes,email",
        success: (user) =>
          @$('> #login').modal('hide')
          # We don't know if this is a signup or a login.
          Parse.Dispatcher.trigger "user:loginStart", user

        error: (user, error) =>