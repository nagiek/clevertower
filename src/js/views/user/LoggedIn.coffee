define [
  "jquery"
  "underscore"
  "backbone"
  "pusher"
  'collections/property/PropertyList',
  "i18n!nls/devise"
  "templates/user/logged_in_menu"
], ($, _, Parse, Pusher, PropertyList, i18nDevise) ->

  class LoggedInView extends Parse.View
    events:
      "click #logout": "logOut"

    el: "#user-menu"
    initialize: ->
      _.bindAll this, "logOut"
      @$el.html JST["src/js/templates/user/logged_in_menu.jst"](i18nDevise: i18nDevise)
      
      Parse.User.current().on "change:type", @render
      
      @pusher = new Pusher 'dee5c4022be4432d7152'
      
      # Create our collection of Properties
      @properties = new PropertyList
      @properties.on "add", @subscribeProperty
      
      # @leases = new LeaseList
      # @leases.on "add", @subscribeLease
      
      @render()

    subscribeProperty: (e) =>
      @pusher.subscribe "property-#{obj.id}"

    subscribeLease: (e) =>
      @pusher.subscribe "lease-#{obj.id}"

    # Logs out the user and shows the login view
    logOut: (e) ->
      Parse.User.logOut()
      Parse.history.navigate "/"
      @trigger "user:change"
      @undelegateEvents();
      delete this

    render: ->
      if Parse.User.current().get("type") is "manager"
        require ["views/property/Manage"], (ManagePropertiesView) =>
          @subview = new ManagePropertiesView(collection: @properties)
          @subview.render()
      else
        require ["views/property/Manage"], (ManagePropertiesView) =>
          @subview = new ManagePropertiesView(collection: @properties)
          @subview.render()
      
      @