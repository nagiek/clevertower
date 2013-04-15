define [
  "jquery"
  "underscore"
  "backbone"
  'models/Profile'
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'plugins/toggler'
  'templates/user/logged_out_menu'
  'templates/user/reset_password'
], ($, _, Parse, Profile, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class LoggedOutView extends Parse.View

    el: "#user-menu"

    events:
      "submit form.login-form"      : "logIn"
      "click .btn-facebook"         : "logInWithFacebook"
      "submit form.signup-form"     : "signUp"
      "click .reset-password-modal" : "showResetPasswordModal"
      # "click .toggle"               : "toggle"

    initialize: ->
      _.bindAll this, "logIn", "signUp", "resetPassword", "showResetPasswordModal"

      Parse.Dispatcher.on "user:login", (user) =>
        $('#reset-password-modal').remove()
        if user.get("type") is "manager"
          network = user.get("network")
          if network and network.get("name")
            # Set the link to the network subdomain.
            domain = "#{location.protocol}://#{network.get("name")}.#{document.domain}" + if location.port then ":#{location.port}"
            $("#network-nav a").prop "href", domain
            @undelegateEvents()
            delete this
          else
            require ["views/network/New"], (NewNetworkView) =>
              Parse.history.navigate "/network/set"
              @view = new NewNetworkView(model: Parse.User.current().get("network")) if !@view or @view !instanceof NetworkFormView
              @view.render()
        else
          @undelegateEvents()
          delete this
        
      @render()

    render: ->
      @$el.html JST["src/js/templates/user/logged_out_menu.jst"](i18nDevise: i18nDevise, i18nUser: i18nUser)
      $('body').append JST["src/js/templates/user/reset_password.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)
      
      # Bind this here instead of events, as it is outside the view.
      $('form#reset-password-form').on "submit", @resetPassword
      # Make toggles
      @$('.toggle').toggler()
      @

    showResetPasswordModal: (e) ->
      $('#reset-password-modal').modal()
      e.preventDefault()

    resetPassword: (e) ->
      e.preventDefault()
      Parse.User.requestPasswordReset $("#reset-email").val(),
        success: ->
          new Alert(event: 'reset-password', message: i18nDevise.messages.password_reset)
          $('#reset-password-modal').find('.error').removeClass('error')
          $('#reset-password-modal').modal('close')
        error: (error) ->
          msg = switch error.code
            when 125 then i18nDevise.errors.invalid_email_format
            when 205 then i18nDevise.errors.username_doesnt_exist
            else error.message
            
          $("#reset-email-group").addClass('error')
          new Alert(event: 'reset-password', fade: false, message: msg, type: 'error')

    logIn: (e) ->
      e.preventDefault()
      @$(".login-form button").attr "disabled", "disabled"
      email = @$("#login-username").val()
      password = @$("#login-password").val()
      Parse.User.logIn email, password,
        success: (user) =>
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user

        error: (user, error) =>
          @$('.login-form .username-group').addClass('error')
          @$('.login-form .password-group').addClass('error')

          msg = switch error.code
            when -1   then i18nDevise.errors.fields_missing
            else i18nDevise.errors.invalid_login
          
          @$(".login-form .alert-error").html(msg).show()
          @$(".login-form button").removeAttr "disabled"

    logInWithFacebook : (e) ->  
      e.preventDefault()
      Parse.FacebookUtils.logIn "user_likes,email",
        success: (user) ->
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user
        error: (user, error) ->
            
    signUp: (e) ->
      e.preventDefault()
      @$(".signup-form button").attr "disabled", "disabled"
      email = @$("#signup-username").val()
      password = @$("#signup-password").val()
      Parse.User.signUp email, password, { email: email, ACL: new Parse.ACL() },
        success: (user) =>
          Parse.Dispatcher.trigger "user:login", user
          Parse.Dispatcher.trigger "user:change", user

        error: (user, error) =>
          @$(".signup-form .error").removeClass('error')
          msg = switch error.code
            when 125  then i18nDevise.errors.invalid_email_format
            when 202  then i18nDevise.errors.username_taken
            when -1   then i18nDevise.errors.fields_missing
            else error.message

          switch error.code
            when 125 or 202 
              @$('.username-group').addClass('error')
            when -1   
              @$('.signup-form username-group').addClass('error')
              @$('.signup-form password-group').addClass('error')

          @$(".signup-form .alert-error").html(msg).show()
          @$(".signup-form button").removeAttr "disabled"
