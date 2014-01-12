define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/sub/apps/facebook"
], ($, _, Parse, Alert, i18nCommon, i18nUser) ->

  class FacebookAppView extends Parse.View
        
    events:
      'click #fb-link'        : 'FBlink'
      'click #fb-unlink'      : 'FBunlink'
    
    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this

    FBlink: (e) =>
      e.preventDefault()
      unless Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.link Parse.User.current(), Parse.App.fbPerms, 
        success: =>
          FB.api '/me', 
            fields: 'friends, first_name, last_name, email, birthday, bio, website, gender, picture.width(270).height(270)', # picture?width=400&height=400
            (response) =>

              console.log response

              userVars = 
                fbFriends: response.friends
                email: response.email
                birthday: new Date response.birthday
                gender: response.gender
              userVars.location = response.location.name if response.location
              Parse.User.current().save userVars
              Parse.User.current().get("profile").save
                fbID: response.id
                email: response.email
                first_name: response.first_name
                last_name: response.last_name
                bio: response.about_me
                website: response.website



          @$("#fb-link").button("reset")
          @$("#fb-link").html i18nCommon.actions.link
          @$(".facebook-group .controls").html "<span class='btn active linked'>#{i18nCommon.adjectives.linked}</span>" +
            "<span></span>" +
            "<button id='fb-unlink' class='btn revoke btn-danger'>#{i18nCommon.actions.revoke_access}</button>"
        error: =>
          @$("#fb-link").button("reset")
          @$("#fb-link").html i18nCommon.actions.link
          new Alert event: 'facebook-link', fade: false, message: i18nCommon.errors.unknown, type: 'danger'

    FBunlink: (e) =>
      e.preventDefault()
      if Parse.User.current()._isLinked("facebook")
        Parse.FacebookUtils.unlink Parse.User.current(), 
        success: =>
          @$("#fb-unlink").button("reset")
          @$("#fb-unlink").html i18nCommon.actions.unlink
          @$(".facebook-group .controls").html "<button id='fb-link' class='btn'>#{i18nCommon.actions.link}</button>"
        error: =>
          @$("#fb-unlink").button("reset")
          @$("#fb-unlink").html i18nCommon.actions.unlink
          new Alert event: 'facebook-link', fade: false, message: i18nCommon.errors.unknown, type: 'danger'
            
    render: =>
      vars =
        fbLinked:     Parse.User.current()._isLinked("facebook")
        i18nCommon:   i18nCommon
        i18nUser:     i18nUser
      
      @$el.html JST["src/js/templates/user/sub/apps/facebook.jst"](vars)
      @