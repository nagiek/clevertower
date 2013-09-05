define [
  "jquery"
  "underscore"
  "backbone"
  "pusher"
  'collections/PropertyList'
  'models/Profile'
  'views/notification/Index'
  "i18n!nls/devise"
  "i18n!nls/user"
  "i18n!nls/common"
  "templates/user/logged_in_menu"
  "templates/user/logged_in_panel"
], ($, _, Parse, Pusher, PropertyList, Profile, NotificationsView, i18nDevise, i18nUser, i18nCommon) ->

  # This handles the panel as well, which is outside its element.
  class LoggedInView extends Parse.View

    el: "#user-menu"

    events:
      "click #logout": "logOut"

    initialize: (attrs) -> 
            
      @pusher = new Pusher 'dee5c4022be4432d7152'

      if Parse.User.current().get("network")
        @pusher.subscribe "networks-#{Parse.User.current().get("network").id}" 
        @listenTo Parse.User.current().get("network").properties, "add", @subscribeProperty

      @listenTo Parse.User.current().get("profile"), "change:image_profile", @updatePic
      @listenTo Parse.User.current().get("profile"), "change:first_name change:last_name", @updateName
                
    subscribeProperty: (obj) =>
      @pusher.subscribe "properties-#{obj.id}"
      
    # subscribeLease: (e) =>
    #   @pusher.subscribe "lease-#{obj.id}"

    # Logs out the user and shows the login view
    logOut: (e) ->
      # Record the user login time for next session.
      Parse.User.current().save {lastLogin: Parse.User.current().updatedAt}, {patch: true}

      Parse.User.logOut()
      Parse.Dispatcher.trigger "user:change"
      Parse.Dispatcher.trigger "user:logout"
      @undelegateEvents()
      delete this

    render: ->
      name = Parse.User.current().get("profile").name()
      vars = 
        src: Parse.User.current().get("profile").cover('micro')
        photo_alt: i18nUser.show.photo(name)
        name: name
        objectId: Parse.User.current().get("profile").id
        i18nUser: i18nUser
        i18nDevise: i18nDevise
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](vars)
      $("#sidebar-user-menu").html JST["src/js/templates/user/logged_in_panel.jst"](vars)
      @notificationsView = new NotificationsView
      @notificationsView.render()
      @

    updateNav: -> 
      @$('#profile-link img').prop "src", Parse.User.current().get("profile").cover("micro")
      $('#sidebar-profile-link img').prop "src", Parse.User.current().get("profile").cover("micro")

    updateName: ->
      @$('#profile-link span').html Parse.User.current().get("profile").name()
      $('#sidebar-profile-link span').html Parse.User.current().get("profile").name()