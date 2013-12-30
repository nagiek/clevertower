define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/login'
], ($, _, Parse, NotificationList, i18nCommon, i18nDevise, i18nUser) ->

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
      @$("> #login-modal #login-modal-form button.btn-primary").button "loading"
      @$("> #login-modal #login-modal-form  .has-error").removeClass 'has-error'
      email = @$("#login-modal-username").val()
      password = @$("#login-modal-password").val()
      Parse.User.logIn email, password,
        success: (user) =>
          @$('> #login-modal').modal('hide')
          Parse.Dispatcher.trigger "user:loginStart"

        error: (user, error) =>
          @$("> #login-modal #login-modal-form button.btn-primary").button "reset"
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

                if response.picture.data and not response.picture.data.is_silhouette

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

        error: (error) =>