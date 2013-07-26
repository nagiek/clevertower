define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/apps_modal"
], ($, _, Parse, Alert, i18nCommon, i18nUser) ->

  # Meant to be a drop in modal for the user to link their accounts.
  class AppsModalView extends Parse.View
    
    id: "apps-modal"
    className: 'modal modal-form fade in'
    
    events:
      'click #fb-link'        : 'FBlink'
      'click #fb-unlink'      : 'FBunlink'
      "close"                 : 'clear'
        
    FBlink: (e) ->
      e.preventDefault()
      unless Parse.User.current().isLinked("facebook")
        Parse.FacebookUtils.link Parse.User.current(), Parse.App.fbPerms, success:
          @$(".facebook-group controls").html "<span class='btn active linked'>#{i18nCommon.adjectives.linked}</span>" +
            "<span></span>" +
            "<button id='fb-unlink' class='btn revoke btn-danger'>#{i18nCommon.actions.revoke_access}</button>"

    FBunlink: (e) ->
      e.preventDefault()
      if Parse.User.current().isLinked("facebook")
        Parse.FacebookUtils.unlink Parse.User.current(), success: 
          @$(".facebook-group controls").html "<button id='fb-link' class='btn'>#{i18nCommon.actions.link}</button>"
    
    render: =>
      vars =
        fbLinked:     Parse.User.current().isLinked("facebook")
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/apps_modal.jst"](vars)
      @

    clear: =>
      @remove()
      @undelegateEvents()
      delete this