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
      @$('#home-nav a').html i18nCommon.verbs.explore

      hostArray = location.host.split(".")
      hostArray.shift()

      # Check if we are on a subdomain or not.
      # We measure hostArray.length > 2 instead of 1 because it is after shift
      homePrefix = if hostArray.length > 1 then '//' + hostArray.join(".") else ""

      @$('#home-nav a').prop "href", homePrefix + "/search"

      if Parse.User.current()

        # Set the link to the network subdomain.
        if Parse.User.current().get("network") 
          networkUrl = if hostArray.length > 1 then "/" else Parse.User.current().get("network").privateUrl()
        else if Parse.User.current().get("property")

          # /manage contains a link to upgrade.
          networkUrl = "/manage"

          # if Parse.User.current().get("mgrOfProp") and !Parse.User.current().get("property").get("network")
          #   networkUrl = "/manage"
          # else networkUrl = "/network/new"

        # We have no network or property.
        else networkUrl = "/account/setup"
        @$('#network-nav').html "<a href='#{networkUrl}'>#{i18nCommon.verbs.manage}</a>"

      else
        @$('#network-nav').html ""
      @
