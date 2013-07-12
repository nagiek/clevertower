define [
  "jquery"
  "underscore"
  "backbone"
  'models/Network'
  "i18n!nls/common"
], ($, _, Parse, Network, i18nCommon) ->

  class UserNavView extends Parse.View

    el: "#domain-menu"
    
    initialize: ->

      # @listenTo Parse.Dispatcher, "user:logout", -> delete @model

      @listenTo Parse.Dispatcher, "user:login", @bindListenEvents
      @listenTo Parse.Dispatcher, "user:change", @render

      @bindListenEvents() if Parse.User.current()
    
    bindListenEvents : ->
      @listenTo Parse.User.current(), "change:network", @render
      @listenTo Parse.User.current().get("network"), "change:name", @render if Parse.User.current().get("network")
      
    render: =>  
      @$('#home-nav a').html i18nCommon.nouns.outside # i18nCommon.verbs.explore
      @$('#network-nav a').html i18nCommon.nouns.inside # #{i18nCommon.verbs.manage}

      # hostArray = location.host.split(".")
      # hostArray.shift()

      # Check if we are on a subdomain or not.
      # We measure hostArray.length > 2 instead of 1 because it is after shift
      # homePrefix = if hostArray.length > 1 then '//' + hostArray.join(".") else ""

      # @$('#home-nav a').prop "href", "/outside" # homePrefix + 

      # if Parse.User.current()

      #   # Set the link to the network subdomain.
      #   if Parse.User.current().get("network") or Parse.User.current().get("property")
      #   #   networkUrl = if hostArray.length > 1 then "/" else Parse.User.current().get("network").privateUrl()
      #   # else if Parse.User.current().get("property")
      #     networkUrl = "/inside"
      #   # We have no network or property.
      #   else networkUrl = "/account/setup"

      #   @$('#network-nav a').prop "href", networkUrl

      @
