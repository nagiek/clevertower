define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/apps"
], ($, _, Parse, Alert, i18nCommon, i18nUser) ->

  class EditAppsView extends Parse.View
    
    el: '#main'
    
    events:
      'click #fb-link'        : 'FBlink'
      'click #fb-unlink'      : 'FBunlink'
    
    initialize : (attrs) ->
      
      _.bindAll this, 'save'
                  
      @on "save:success", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
    
    FBlink: (e) ->
      e.preventDefault()
      unless Parse.FacebookUtils.isLinked(Parse.User.current())
        Parse.FacebookUtils.link Parse.User.current(), 
          success: (user) ->
            alert("The user is no longer associated with their Facebook account.")

    FBunlink: (e) ->
      e.preventDefault()
      if Parse.FacebookUtils.isLinked(Parse.User.current())
        Parse.FacebookUtils.unlink Parse.User.current(), 
          success: (user) ->
            alert("The user is no longer associated with their Facebook account.")
            
    render: ->
      vars =
        fbLinked:     Parse.FacebookUtils.isLinked(Parse.User.current())
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/apps.jst"](vars)
      @