define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/devise"
  "plugins/toggler"
  "templates/user/sub/settings"
  "templates/user/form"
], ($, _, Parse, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class AccountSettingsView extends Parse.View
    
    el: '#settings'
    
    events:
      'submit form'           : 'save'
      "click #reset-password" : 'resetPassword'
    
    initialize : (attrs) ->

      @model = Parse.User.current()
                  
      @listenTo @model, 'invalid', (error) =>
        @$('button.save').button "reset"
        msg = i18nDevise.errors[error.message]
                  
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
        
        switch error.message
          when "missing_password"         then @$('.password-group').addClass('has-error')
          when "invalid login parameters" then @$('.password-group').addClass('has-error')
          when "invalid_email"            then @$('.email-group').addClass('has-error')
          when "missing_passwords"        then @$('.new-password-group').addClass('has-error')
          when 'unmatching_passwords'     then @$('.new-password-group').addClass('has-error')
      
      @on "save:success", (model) =>
        @$('button.save').button "reset"
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'

    resetPassword: (e) =>
    
      Parse.User.requestPasswordReset @model.getEmail(),
        success: ->
          new Alert event: 'reset-password', message: i18nDevise.messages.password_reset
    
    # Save is broken into two saves: User and profile.
    # Profile is always available, but user may be hidden.
    save : (e) =>
      e.preventDefault()
      @$('button.save').button "loading"
      @$('.has-error').removeClass('has-error')
      data = @$('form').serializeObject()
      
      # Extra security for username/password
      if data.user.new_password or data.user.new_password_confirm or (data.user.email and data.user.email isnt Parse.User.current().getEmail())
        return @model.trigger "invalid", {message: "missing_password"} unless data.user.password      
        Parse.User.logIn @model.getUsername(), data.user.password, 
        success: =>
          # Email security
          data.user.username = data.user.email if data.user.email
      
          # Password security
          if data.user.new_password or data.user.new_password_confirm
            if data.user.new_password and data.user.new_password_confirm
              if data.user.new_password is data.user.new_password_confirm 
                data.user.password = data.user.new_password
              else return @model.trigger "invalid", {message: "unmatching_passwords"}
            else return @model.trigger "invalid", {message: "missing_passwords"}
          else
            delete data.user.password

          @model.save data.user,
          success: (model) =>
            @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
            @trigger "save:success", model, this
          error: (model, error) => 
            @model.trigger "invalid", error
            
      # We are saving just the type.
      else
        @model.save data.user.type,
        success: (model) =>
          @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
          @trigger "save:success", model, this
        error: (model, error) => 
          @model.trigger "invalid", error
          
      error: (model, error) =>
        @model.trigger "invalid", error
        
    render: ->
      
      vars = _.merge @model.toJSON(),
        email: @model.getEmail()
        cancel_path: "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon: i18nCommon
        i18nDevise: i18nDevise
      vars.type = 'tenant' unless vars.type

      @$el.html JST["src/js/templates/user/sub/settings.jst"](vars)
      
      @$('.toggle').toggler()
      @