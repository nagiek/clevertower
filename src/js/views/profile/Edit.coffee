define [
  "jquery"
  "underscore"
  "backbone"
  "models/Profile"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/profile/edit"
], ($, _, Parse, Profile, Alert, i18nCommon, i18nUser) ->

  class EditProfileView extends Parse.View
    
    el: '#main'
    
    events:
      'submit form'          : 'save'
    
    initialize : (attrs) ->
      
      @current = attrs.current
                  
      @model.on 'invalid', (error) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        
        msg = i18nUser.errors[error.message]
                  
        new Alert(event: 'model-save', fade: false, message: msg, type: 'error')

        switch error.message
          when "invalid_birthday"
            @$('.birthday-group').addClass('error')
      
      @on "save:success", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
      
    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this

    # Save is broken into two saves: User and profile.
    # Profile is always available, but user may be hidden.
    save : (e) =>
      e.preventDefault()
      data = @$('form').serializeObject()
      
      # Set name on every request.
      first_name = data.profile.first_name
      last_name = data.profile.last_name
      data.profile.name = if data.profile.first_name or data.profile.last_name then "#{first_name} #{last_name}".trim() else ""

      @model.save data.profile,
      success: (model) =>
        @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
        @trigger "save:success", model, this
      error: (model, error) => 
        @model.trigger "invalid", error
        
      if data.user and @current
        
        # Massage the Only-String data from serializeObject()
        if data.user.birthday.year and data.user.birthday.month and data.user.birthday.day
          data.user.birthday = new Date(data.user.birthday.year, data.user.birthday.month, data.user.birthday.day) 
        else if data.user.birthday.year or data.user.birthday.month or data.user.birthday.day
          @model.trigger "invalid", {message: 'invalid_birthday'}
        else
          delete data.user.birthday
        
        Parse.User.current().save data.user
        
    render: ->
      
      vars = _.merge(
        @model.toJSON(),
        current: @current
        cancel_path: "/users/#{@model.id}"
        i18nCommon: i18nCommon
        i18nUser: i18nUser
      )
      
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/profile/edit.jst"](vars)
      
      if @current
        # Set select attributes.
        # @current is only checked because coincidentally both selects are User (not Profile) fields.
        birthday = Parse.User.current().get "birthday"
        if birthday
          birthday = new Date(birthday)
          month = birthday.getMonth()
          day = birthday.getDate()
          year = birthday.getFullYear()
          @$(".month option[value='#{month}']").prop "selected", "selected"
          @$(".day option[value='#{day}']").prop "selected", "selected"
          @$(".year option[value='#{year}']").prop "selected", "selected"
        
        gender = Parse.User.current().get "gender"
        if gender
          @$(".gender option[value='#{gender}']").prop "selected", "selected"        
        