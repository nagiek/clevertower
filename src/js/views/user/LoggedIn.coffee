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
  "templates/user/logged_in_menu"
], ($, _, Parse, Pusher, PropertyList, Profile, NotificationsView, i18nDevise, i18nUser) ->

  class LoggedInView extends Parse.View

    el: "#user-menu"

    events:
      "click #logout": "logOut"

    initialize: (attrs) ->
            
      @pusher = new Pusher 'dee5c4022be4432d7152'

      if Parse.User.current().get("network")
        @pusher.subscribe "networks-#{Parse.User.current().get("network").id}" 
        @listenTo Parse.User.current().get("network").properties, "add", @subscribeProperty

      @listenTo Parse.User.current().profile, "sync", @updateNav
      @render()
          
    registerUser : =>
      # Load the properties if the user has just logged in.

      
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
      name = Parse.User.current().profile.name()
      vars = 
        src: Parse.User.current().profile.cover('micro')
        photo_alt: i18nUser.show.photo(name)
        name: name
        objectId: Parse.User.current().profile.id
        i18nUser: i18nUser
        i18nDevise: i18nDevise

      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](vars)
      @notificationsView = new NotificationsView
      @notificationsView.render()
      @


    updateNav: ->
      @$('#profile-link img').prop "src", Parse.User.current().profile.cover("micro")
      @$('#profile-link span').html Parse.User.current().profile.name()