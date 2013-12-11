define [
  "jquery"
  "underscore"
  "backbone"
  "models/Profile"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/sub/privacy"
], ($, _, Parse, Profile, Alert, i18nCommon, i18nUser) ->

  class EditPrivacyView extends Parse.View
    
    el: '#privacy'
    
    events:
      'submit form'           : 'save'
    
    initialize : (attrs) ->
      
      @model = Parse.User.current().get("profile")

      @listenTo @model, 'invalid', (error) =>
        @$('button.save').button "reset"        
        msg = i18nUser.errors[error.message]
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'

      @on "save:success", (model) =>
        @$('button.save').button "reset"
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
    
    save : (e) =>
      e.preventDefault()
      @$('.has-error').removeClass('has-error')
      @$('button.save').button "loading"

      attrs = @model.scrub @$('form').serializeObject().profile 

      @model.save attrs,
      success: (model) =>
        @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
        @trigger "save:success", model, this
      error: (model, error) => 
        @model.trigger "invalid", error
                
    render: ->
      vars = _.merge @model.toJSON(),
        baseUrl: "/users/#{@model.id}"
        i18nCommon: i18nCommon
        i18nUser: i18nUser
      
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/user/sub/privacy.jst"](vars)
      @