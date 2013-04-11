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
    events:
      "click #logout": "logOut"

    el: "#user-menu"
    initialize: (attrs) ->
      _.bindAll this, "render", "changeName", "logOut"
      
      @onNetwork = attrs.onNetwork
      
      @pusher = new Pusher 'dee5c4022be4432d7152'

      # Parse.User.current().leases.on "add", @subscribeLease
      
      if @onNetwork then @registerUser()
      
      # Load the profile if the user has just logged in.
      if Parse.User.current().profile
        Parse.User.current().profile.on "sync", @changeName
        @render()
      else
        (new Parse.Query(Profile)).equalTo("user", Parse.User.current()).first()
        .then (profile) => 
          Parse.User.current().profile = profile
          Parse.User.current().profile.on "sync", @changeName
          @render()
          
    registerUser : =>
      # Load the properties if the user has just logged in.
      Parse.User.current().properties = new PropertyList unless Parse.User.current().properties
      Parse.User.current().properties.on "add", @subscribeProperty
      
    subscribeProperty: (obj) =>
      @pusher.subscribe "property-#{obj.id}"
      
    # subscribeLease: (e) =>
    #   @pusher.subscribe "lease-#{obj.id}"

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      Parse.history.navigate "/"
      @trigger "user:change"
      @trigger "user:logout"
      @undelegateEvents();
      delete this

    render: ->
      vars = _.merge(
        objectId: Parse.User.current().profile.id
        i18nUser: i18nUser
        i18nDevise: i18nDevise
      )
      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](vars)
      @changeName Parse.User.current().profile
      @notificationsView = new NotificationsView
      @notificationsView.render()
      @
      
    changeName: (model) ->      
      name = model.get "name" if model
      name = Parse.User.current().getUsername() unless name?
      @$('#profile-link').html name