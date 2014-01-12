define [
  "jquery"
  "underscore"
  "backbone"
  "views/user/sub/apps/facebook"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/sub/apps"
], ($, _, Parse, FacebookAppView, i18nCommon, i18nUser) ->

  class EditAppsView extends Parse.View
    
    el: '#apps'
    
    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this

    render: =>
      vars =
        cancel_path:  "/users/#{Parse.User.current().get('profile').id}"
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/sub/apps.jst"](vars)

      @$(".facebook-group").html new FacebookAppView().render().el
      @