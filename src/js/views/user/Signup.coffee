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
      Parse.FacebookUtils.logIn Parse.App.fbPerms,
        success: (user) =>

          # We don't know if this is a signup or a login. 
          @$('> #login-modal').modal('hide')
          @$('> #signup-modal').modal('hide')

          # Must run through login-start process in-sync, without trigger, as we may change the profile.
          Parse.User.current().setup().then =>
            unless Parse.User.current().get("email")
              FB.api '/me', (response) ->
                userVars = 
                  email: response.email
                  birthday: new Date response.birthday
                  gender: response.gender
                userVars.location = response.location.name if response.location
                Parse.User.current().save userVars
                Parse.User.current().get("profile").save
                  email: response.email
                  first_name: response.first_name
                  last_name: response.last_name

              # We need at least width=270
              FB.api '/me/picture?width=400&height=400', (response) ->
                if response.data and not response.data.is_silhouette

                  Parse.Cloud.run "SetPicture", {
                    url: response.data.url
                  },
                  success: (res) ->
                    Parse.User.current().get("profile").set
                      image_full: res
                      image_profile: res
                      image_thumb: res
                  error: (res) -> console.log res

              # Have the user set a password before moving on.
              Parse.history.navigate "account/edit", true

            else

              # Normal Login Routing.
              if Parse.User.current().get("network") or Parse.User.current().get("property")
                # Reload the current path. 
                # Don't use navigate, as it will fail.
                # The route functions themselves are responsible for altering content.
                Parse.history.loadUrl location.pathname
              else
                # require ["views/helper/Alert", 'i18n!nls/property'], (Alert, i18nProperty) =>
                #   new Alert
                #     event:    'no_network'
                #     type:     'warning'
                #     fade:     true
                #     heading:  i18nProperty.errors.network_not_set
                Parse.history.navigate "account/setup", true

            Parse.Dispatcher.trigger "user:login", user
            Parse.Dispatcher.trigger "user:change", user
            @$('#reset-password-modal').remove()
            @$('#signup-modal').remove()
            @$('#login-modal').remove()

            @stopListening()
            @undelegateEvents()
            delete this

        error: (error) =>