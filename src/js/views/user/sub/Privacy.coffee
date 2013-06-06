define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/sub/privacy"
], ($, _, Parse, Alert, i18nCommon, i18nUser) ->

  class EditPrivacyView extends Parse.View
    
    el: '#privacy'
    
    events:
      'submit form'           : 'save'
    
    initialize : (attrs) ->
      
      @model = Parse.User.current()
                  
      @on "save:success", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
    
    save : (e) =>
      e.preventDefault()
      
      data = @$('form').serializeObject()

      @model.save data.user,
      success: (model) =>
        @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
        @trigger "save:success", model, this
                
    render: ->
      vars = _.merge @model.toJSON(),
        cancel_path: "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon: i18nCommon
        i18nUser: i18nUser
      
      _.defaults vars, Parse.User::defaults
      @$el.html JST["src/js/templates/user/sub/privacy.jst"](vars)
      @