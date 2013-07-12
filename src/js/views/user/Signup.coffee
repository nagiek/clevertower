define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'plugins/toggler'
  'templates/user/signup'
], ($, _, Parse, NotificationList, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class SignupView extends Parse.View

    el: "#main"

    events:
      "submit form#signup-form"       : "signUp"
      "click .btn-facebook"                 : "logInWithFacebook"

    render: =>
      @$el.html JST["src/js/templates/user/signup.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      
      # Make toggles
      @$('.toggle').toggler()
      @

    signUp: (e) =>
      e.preventDefault()
      @$("#signup-form button").prop "disabled", "disabled"
      email = @$("#signup-username").val()
      password = @$("#signup-password").val()
      user_type = if @$(".type-group :checked").prop('id') is 'signup-tenant' then 'tenant' else 'manager'
      Parse.User.signUp email, password, { user_type: user_type, email: email, ACL: new Parse.ACL() },
        success: (user) =>
          @$("#signup-form button").removeProp "disabled"

          # Skip the user-setup phase, as we will not have anything to add.
          # Only extra things we need are the profile and notifications.

          profile = user.get("profile")
          profile.set "email", user.get("email")

          Parse.User.current().set "profile", profile
          Parse.User.current().notifications = new NotificationList

          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user
          Parse.history.navigate "/account/setup", trigger: true

        error: (user, error) =>
          @$("#signup-form .error").removeClass 'error'
          @$("#signup-form button").removeProp "disabled"
          msg = switch error.code
            when 125  then i18nDevise.errors.invalid_email_format
            when 202  then i18nDevise.errors.username_taken
            when -1   then i18nDevise.errors.fields_missing
            else error.message

          switch error.code
            when 125 or 202 
              @$('.username-group').addClass('error')
            when -1   
              @$('> #signup #signup-form username-group').addClass('error')
              @$('> #signup #signup-form password-group').addClass('error')

          @$("> #signup #signup-form .alert-error").html(msg).show()

    logInWithFacebook : (e) =>  
      e.preventDefault()
      Parse.FacebookUtils.logIn "user_likes,email",
        success: (user) =>
          @$('> #login').modal('hide')
          # We don't know if this is a signup or a login.
          Parse.Dispatcher.trigger "user:loginStart", user

        error: (user, error) =>