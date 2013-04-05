define [
  "jquery"
  "underscore"
  "backbone"
  "pusher"
  'collections/property/PropertyList'
  'views/notification/Index'
  "i18n!nls/devise"
  "i18n!nls/user"
  "templates/user/logged_in_menu"
], ($, _, Parse, Pusher, PropertyList, NotificationsView, i18nDevise, i18nUser) ->

  class LoggedInView extends Parse.View
    events:
      "click #logout": "logOut"

    el: "#user-menu"
    initialize: ->
      _.bindAll this, "logOut"
      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](i18nUser: i18nUser, i18nDevise: i18nDevise)
      
      Parse.User.current().on "change:type", @render
      @pusher = new Pusher 'dee5c4022be4432d7152'

      # subscribeLease: (e) =>
      #   @pusher.subscribe "lease-#{obj.id}"
      
      @notificationsView = new NotificationsView
      # @leases = new LeaseList
      # @leases.on "add", @subscribeLease
      
      # Create our collection of Properties
      if !Parse.User.current().properties then Parse.User.current().properties = new PropertyList
      Parse.User.current().properties.on "add", @subscribeProperty

    subscribeProperty: (obj) =>
      @pusher.subscribe "property-#{obj.id}"

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      Parse.history.navigate "/"
      @trigger "user:change"
      @undelegateEvents();
      delete this

    render: ->
      @notificationsView.render()
      @