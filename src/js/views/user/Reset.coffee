define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  'views/helper/Alert'
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  'templates/user/reset'
], ($, _, Parse, NotificationList, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class ResetPasswordView extends Parse.View

    el: "#main"

    events:
      "submit form#reset-password-form"     : "resetPassword"

    render: =>
      @$el.html JST["src/js/templates/user/reset.jst"](i18nCommon: i18nCommon, i18nDevise: i18nDevise)

      @

    resetPassword: (e) =>
      e.preventDefault()
      Parse.User.requestPasswordReset $("#reset-email").val(),
        success: =>
          new Alert event: 'reset-password', message: i18nDevise.messages.password_reset
          @$('> #reset-password-modal').find('.has-error').removeClass('has-error')
          @$('> #reset-password-modal').modal('hide')
        error: (error) =>
          msg = switch error.code
            when 125 then i18nDevise.errors.invalid_email_format
            when 205 then i18nDevise.errors.username_doesnt_exist
            else error.message
            
          @$("#reset-email-group").addClass('has-error')
          new Alert event: 'reset-password', fade: false, message: msg, type: 'danger'
