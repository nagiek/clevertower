define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  "load-image"
  "canvas-to-blob"
  'plugins/toggler'
  'templates/user/logged_out_modals'
], ($, _, Parse, NotificationList, Alert, i18nCommon, i18nDevise, i18nUser, loadImage) ->

  class LoggedOutModalsView extends Parse.View

    el: "body"

    events:
      "submit form#login-modal-form"        : "logIn"
      "submit form#signup-modal-form"       : "signUp"
      "submit form#reset-password-form"     : "resetPassword"
      "click #switch-signup-modal"          : "switchToSignup"
      "click #switch-login-modal"           : "switchToLogin"
      "click #login-modal-form .reset-password-link" : "switchToResetPassword"
      "click .btn-facebook"                 : "logInWithFacebook"

    initialize: ->

      @listenTo Parse.Dispatcher, "user:loginStart", @startLogin
      @listenTo Parse.Dispatcher, "user:loginEnd", @finalizeLogin


    startLogin: => Parse.User.current().setup().then -> Parse.Dispatcher.trigger "user:loginEnd"

    finalizeLogin: =>
      Parse.Dispatcher.trigger "user:login"
      Parse.Dispatcher.trigger "user:change"
      @$('#reset-password-modal').remove()
      @$('#signup-modal').remove()
      @$('#login-modal').remove()

      @stopListening()
      @undelegateEvents()
      delete this

    render: =>
      @$el.append JST["src/js/templates/user/logged_out_modals.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      
      # Make toggles
      @$('#signup-modal .toggle').toggler()
      @

    resetPassword: (e) =>
      e.preventDefault()
      Parse.User.requestPasswordReset $("#reset-email").val(),
        success: ->
          new Alert event: 'reset-password', message: i18nDevise.messages.password_reset
          @$('> #reset-password-modal').find('.has-error').removeClass('has-error')
          @$('> #reset-password-modal').modal('hide')
        error: (error) ->
          console.log error
          msg = switch error.code
            when 125 then i18nDevise.errors.invalid_email_format
            when 205 then i18nDevise.errors.username_doesnt_exist
            else error.message
            
          $("#reset-email-group").addClass('has-error')
          new Alert event: 'reset-password', fade: false, message: msg, type: 'danger'

    logIn: (e) =>
      e.preventDefault()
      @$("> #login-modal #login-modal-form button").prop "disabled", "disabled"
      email = @$("#login-modal-username").val()
      password = @$("#login-modal-password").val()
      Parse.User.logIn email, password,
        success: (user) =>
          @$('> #login-modal').modal('hide')
          Parse.Dispatcher.trigger "user:loginStart", user

        error: (error) =>
          console.log error
          @$("> #login-modal #login-modal-form button").removeProp "disabled"
          @$('> #login-modal #login-modal-form .username-group').addClass('has-error')
          @$('> #login-modal #login-modal-form .password-group').addClass('has-error')

          msg = switch error.code
            when -1   then i18nDevise.errors.fields_missing
            else i18nDevise.errors.invalid_login
          
          @$("> #login-modal #login-modal-form .alert-danger").html(msg).show()

    logInWithFacebook : (e) =>  
      e.preventDefault()
      Parse.FacebookUtils.logIn Parse.App.fbPerms,
        success: (user) =>

          # We don't know if this is a signup or a login. 
          @$('> #login-modal').modal('hide')
          @$('> #signup-modal').modal('hide')

          if user.existed() then Parse.Dispatcher.trigger "user:loginStart"
          else

            # Must run through login-start process in-sync, without trigger, as we may change the profile.
            Parse.User.current().setup().then =>
              # User signed up and logged in through Facebook
              FB.api '/me', 
              fields: 'first_name, last_name, email, birthday, bio, website, gender, picture.width(270).height(270)', # picture?width=400&height=400
              (response) =>

                console.log response

                userVars = 
                  email: response.email
                  birthday: new Date response.birthday
                  gender: response.gender
                  ACL: new Parse.ACL()
                userVars.location = response.location.name if response.location
                Parse.User.current().save userVars
                Parse.User.current().get("profile").save
                  email: response.email
                  first_name: response.first_name
                  last_name: response.last_name
                  bio: response.about_me
                  website: response.website

                if response.picture and response.picture.data and not response.picture.data.is_silhouette

                  Parse.Cloud.run "SetPicture", {
                    url: response.picture.data.url
                  },
                  success: (res) =>
                    Parse.User.current().get("profile").set
                      image_full: res
                      image_profile: res
                      image_thumb: res
                    Parse.Dispatcher.trigger "user:loginEnd"
                  error: (res) -> console.log res

                else 
                  Parse.Dispatcher.trigger "user:loginEnd"

        error: (error) => console.log error
            
    signUp: (e) =>
      e.preventDefault()
      @$("> #signup-modal #signup-modal-form button").prop "disabled", "disabled"
      email = @$("#signup-modal-username").val()
      password = @$("#signup-modal-password").val()
      user_type = if @$(".type-group :checked").prop('id') is 'signup-modal-tenant' then 'tenant' else 'manager'
      Parse.User.signUp email, password, { user_type: user_type, email: email, ACL: new Parse.ACL() },
        success: (user) =>
          @$('> #signup-modal').modal('hide')
          @$("> #signup-modal #signup-modal-form button").removeProp "disabled"

          # Skip the user-setup phase, as we will not have anything to add.
          # Only extra things we need are the profile and notifications.

          profile = user.get("profile")
          profile.set "email", user.get("email")

          Parse.User.current().set "profile", profile
          Parse.User.current().notifications = new NotificationList

          Parse.Dispatcher.trigger "user:login"
          Parse.Dispatcher.trigger "user:change"
          Parse.history.navigate "/account/setup", trigger: true

        error: (error) =>
          console.log error
          @$("> #signup-modal #signup-modal-form .has-error").removeClass 'has-error'
          @$("> #signup-modal #signup-modal-form button").removeProp "disabled"
          msg = switch error.code
            when 125  then i18nDevise.errors.invalid_email_format
            when 202  then i18nDevise.errors.username_taken
            when -1   then i18nDevise.errors.fields_missing
            else error.message

          switch error.code
            when 125 or 202 
              @$('.username-group').addClass('has-error')
            when -1   
              @$('> #signup-modal #signup-modal-form username-group').addClass('has-error')
              @$('> #signup-modal #signup-modal-form password-group').addClass('has-error')

          @$("> #signup-modal #signup-modal-form .alert-danger").html(msg).show()

    switchToSignup: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #signup-modal').modal()
      @$("#signup-modal-username").focus()
    switchToLogin: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #login-modal').modal()
      @$("#login-modal-username").focus()
    switchToResetPassword: (e) =>
      e.preventDefault()
      @$('> .modal.in').modal('hide')
      @$('> #reset-password-modal').modal()
      @$find("#reset-email").focus()