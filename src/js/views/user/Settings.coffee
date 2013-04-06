define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/devise"
  "templates/user/settings"
], ($, _, Parse, Alert, i18nCommon, i18nDevise) ->

  class EditProfileView extends Parse.View
    
    el: '#main'
    
    events:
      'submit form'           : 'save'
      "click #reset-password" : 'resetPassword'
    
    initialize : (attrs) ->
      
      _.bindAll this, 'save', 'resetPassword'
                  
      @model.on 'invalid', (error) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        
        msg = i18nDevise.errors[error.message]
                  
        new Alert(event: 'model-save', fade: false, message: msg, type: 'error')
        
        switch error.message
          when "missing_password"         then @$('.password-group').addClass('error')
          when "invalid login parameters" then @$('.password-group').addClass('error')
          when "invalid_email"            then @$('.email-group').addClass('error')
          when "missing_passwords"        then @$('.new-password-group').addClass('error')
          when 'unmatching_passwords'     then @$('.new-password-group').addClass('error')
      
      @on "save:success", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')

    resetPassword: (e) ->
    
      Parse.User.requestPasswordReset @model.getEmail(),
        success: ->
          new Alert(event: 'reset-password', message: i18nDevise.messages.password_reset)    
    
    # Save is broken into two saves: User and profile.
    # Profile is always available, but user may be hidden.
    save : (e) ->
      e.preventDefault()
      
      data = @$('form').serializeObject()
      return @model.trigger "invalid", {message: "missing_password"} unless data.user.password
      
      console.log @model.getUsername()
      
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
                
        delete data.user.new_password
        delete data.user.new_password_confirm

        @model.save data.user,
        success: (model) =>
          @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
          @trigger "save:success", model, this
        error: (model, error) => 
          console.log error
          @model.trigger "invalid", error
          
      error: (model, error) =>
        @model.trigger "invalid", error
        
    render: ->
      
      vars = _.merge @model.toJSON(),        
        email: @model.getEmail()
        cancel_path: "/users/#{Parse.User.current().profile.id}"
        i18nCommon: i18nCommon
        i18nDevise: i18nDevise
      
      @$el.html JST["src/js/templates/user/settings.jst"](vars)