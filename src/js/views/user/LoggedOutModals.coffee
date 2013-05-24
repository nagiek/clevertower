define [
  "jquery"
  "underscore"
  "backbone"
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'plugins/toggler'
  'templates/user/logged_out_modals'
], ($, _, Parse, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class LoggedOutModalsView extends Parse.View

    el: "body"

    events:
      "submit form#login-form"              : "logIn"
      "submit form#signup-form"             : "signUp"
      "submit form#reset-password-form"     : "resetPassword"
      "click #switch-signup"                : "switchToSignup"
      "click #switch-login"                 : "switchToLogin"
      "click .reset-password-link"          : "switchToResetPassword"
      "click .btn-facebook"                 : "logInWithFacebook"

    initialize: ->

      Parse.Dispatcher.on "user:login", (user) =>
        @$('#reset-password-modal').remove()
        @$('#signup-modal').remove()
        @$('#login-modal').remove()

        @undelegateEvents()
        delete this

    render: =>
      @$el.append JST["src/js/templates/user/logged_out_modals.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      
      # Make toggles
      @$('.toggle').toggler()
      @

    resetPassword: (e) =>
      e.preventDefault()
      Parse.User.requestPasswordReset $("#reset-email").val(),
        success: ->
          new Alert(event: 'reset-password', message: i18nDevise.messages.password_reset)
          @$('> #reset-password-modal').find('.error').removeClass('error')
          @$('> #reset-password-modal').modal('close')
        error: (error) ->
          msg = switch error.code
            when 125 then i18nDevise.errors.invalid_email_format
            when 205 then i18nDevise.errors.username_doesnt_exist
            else error.message
            
          $("#reset-email-group").addClass('error')
          new Alert(event: 'reset-password', fade: false, message: msg, type: 'error')

    logIn: (e) =>
      e.preventDefault()
      @$("> #login-modal #login-form button").attr "disabled", "disabled"
      email = @$("#login-username").val()
      password = @$("#login-password").val()
      Parse.User.logIn email, password,
        success: (user) =>
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user
          @$('> #login-modal').modal('close')

        error: (user, error) =>
          @$('> #login-modal #login-form .username-group').addClass('error')
          @$('> #login-modal #login-form .password-group').addClass('error')

          msg = switch error.code
            when -1   then i18nDevise.errors.fields_missing
            else i18nDevise.errors.invalid_login
          
          @$("> #login-modal #login-form .alert-error").html(msg).show()
          @$("> #login-modal #login-form button").removeAttr "disabled"

    logInWithFacebook : (e) =>  
      e.preventDefault()
      Parse.FacebookUtils.logIn "user_likes,email",
        success: (user) ->
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user
          @$('> .modal.in').modal('close')
        error: (user, error) ->
            
    signUp: (e) =>
      e.preventDefault()
      @$("> #signup-modal #signup-form button").attr "disabled", "disabled"
      email = @$("#signup-username").val()
      password = @$("#signup-password").val()
      type = if @$(".type-group :selected").prop('id') is 'signup-tenant' then 'tenant' else 'manager'
      Parse.User.signUp email, password, { type: type, email: email, ACL: new Parse.ACL() },
        success: (user) =>
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user
          @$('> #signup-modal').modal('close')

        error: (user, error) =>
          @$("> #signup-modal #signup-form .error").removeClass('error')
          console.log error
          msg = switch error.code
            when 125  then i18nDevise.errors.invalid_email_format
            when 202  then i18nDevise.errors.username_taken
            when -1   then i18nDevise.errors.fields_missing
            else error.message

          switch error.code
            when 125 or 202 
              @$('.username-group').addClass('error')
            when -1   
              @$('> #signup-modal #signup-form username-group').addClass('error')
              @$('> #signup-modal #signup-form password-group').addClass('error')

          @$("> #signup-modal #signup-form .alert-error").html(msg).show()
          @$("> #signup-modal #signup-form button").removeAttr "disabled"


    switchToSignup: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #signup-modal').modal()
    switchToLogin: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #login-modal').modal()
    switchToResetPassword: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #reset-password-modal').modal()