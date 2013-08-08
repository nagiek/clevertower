define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/sub/apps"
], ($, _, Parse, Alert, i18nCommon, i18nUser) ->

  class EditAppsView extends Parse.View
    
    el: '#apps'
    
    events:
      'click #fb-link'        : 'FBlink'
      'click #fb-unlink'      : 'FBunlink'
    
    initialize : (attrs) ->
                  
      @on "save:success", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
        
    FBlink: (e) =>
      e.preventDefault()
      unless Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.link Parse.User.current(), Parse.App.fbPerms, 
        success: =>
          @$("#fb-link").button("complete")
          @$("#fb-link").html i18nCommon.actions.link
          @$(".facebook-group .controls").html "<span class='btn active linked'>#{i18nCommon.adjectives.linked}</span>" +
            "<span></span>" +
            "<button id='fb-unlink' class='btn revoke btn-danger'>#{i18nCommon.actions.revoke_access}</button>"
        error: =>
          @$("#fb-link").button("complete")
          @$("#fb-link").html i18nCommon.actions.link
          new Alert(event: 'facebook-link', fade: false, message: i18nCommon.errors.unknown, type: 'error')

    FBunlink: (e) =>
      e.preventDefault()
      if Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.unlink Parse.User.current(), 
        success: =>
          @$("#fb-unlink").button("complete")
          @$("#fb-unlink").html i18nCommon.actions.unlink
          @$(".facebook-group .controls").html "<button id='fb-link' class='btn'>#{i18nCommon.actions.link}</button>"
        error: =>
          @$("#fb-unlink").button("complete")
          @$("#fb-unlink").html i18nCommon.actions.unlink
          new Alert(event: 'facebook-link', fade: false, message: i18nCommon.errors.unknown, type: 'error')
            
    render: =>
      vars =
        fbLinked:     Parse.User.current()._isLinked("facebook")
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/sub/apps.jst"](vars)
      @