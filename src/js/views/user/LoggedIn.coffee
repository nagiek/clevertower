define [
  "jquery"
  "underscore"
  "backbone"
  "pusher"
  'collections/property/PropertyList'
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
      _.bindAll this, "render", "updateNav", "logOut"
      
      @pusher = new Pusher 'dee5c4022be4432d7152'

      network = Parse.User.current().get("network")
      @pusher.subscribe "networks-#{network.id}" if network
      
      network.properties.on "add", @subscribeProperty if Parse.onNetwork

      Parse.User.current().profile.on "sync", @updateNav
      @render()
          
    registerUser : =>
      # Load the properties if the user has just logged in.

      
    subscribeProperty: (obj) =>
      @pusher.subscribe "properties-#{obj.id}"
      
    # subscribeLease: (e) =>
    #   @pusher.subscribe "lease-#{obj.id}"

    # Logs out the user and shows the login view
    logOut: (e) ->
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