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
    
    FBlink: (e) ->
      e.preventDefault()
      unless Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.link Parse.User.current(), Parse.App.fbPerms, success:
          @$(".facebook-group controls").html "<span class='btn active linked'>#{i18nCommon.adjectives.linked}</span>" +
            "<span></span>" +
            "<button id='fb-unlink' class='btn revoke btn-danger'>#{i18nCommon.actions.revoke_access}</button>"

    FBunlink: (e) ->
      e.preventDefault()
      if Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.unlink Parse.User.current(), success: 
          @$(".facebook-group controls").html "<button id='fb-link' class='btn'>#{i18nCommon.actions.link}</button>"
            
    render: =>
      vars =
        fbLinked:     Parse.User.current()._isLinked("facebook")
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/sub/apps.jst"](vars)
      @