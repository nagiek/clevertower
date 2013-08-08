define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "views/user/sub/Apps"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/apps_modal"
], ($, _, Parse, Alert, UserAppsView, i18nCommon, i18nUser) ->

  # Meant to be a drop in modal for the user to link their accounts.
  class AppsModalView extends UserAppsView
    
    id: "apps-modal"
    className: 'modal modal-form fade in'
    
    events:
      'click #fb-link'        : 'FBlink'
      'click #fb-unlink'      : 'FBunlink'
      "close"                 : 'clear'
    
    render: =>
      vars =
        fbLinked:     Parse.User.current()._isLinked("facebook")
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/apps_modal.jst"](vars)
      @

    clear: =>
      @remove()
      @undelegateEvents()
      delete this