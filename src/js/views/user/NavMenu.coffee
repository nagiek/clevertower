define [
  "jquery"
  "underscore"
  "backbone"
  'models/Network'
  "i18n!nls/common"
  "templates/user/nav_menu_network"
], ($, _, Parse, Network, i18nCommon) ->

  # This handles the panel as well, which is outside its element.
  class UserNavView extends Parse.View

    el: "#primary-nav"

    events:
      "click #network-nav a" : "checkForLogin"
      "click #following-nav a" : "checkForLogin"
    
    initialize: ->

      # @listenTo Parse.Dispatcher, "user:logout", -> delete @model
      # @listenTo Parse.Dispatcher, "user:login", @bindListenEvents
      @listenTo Parse.Dispatcher, "user:change", @render

      # @bindListenEvents() if Parse.User.current()
    
    # bindListenEvents : ->
    #   @listenTo Parse.User.current(), "change:network", @render
    #   @listenTo Parse.User.current().get("network"), "change:name", @render if Parse.User.current().get("network")
      
    checkForLogin: (e) ->
      unless Parse.User.current()
        $("#login-modal").modal()
        e.preventDefault()

    render: =>  
      @$('#home-nav a').html i18nCommon.nouns.outside # i18nCommon.verbs.explore
      @$('#following-nav a').html i18nCommon.nouns.following # i18nCommon.verbs.explore

      if Parse.User.current() and Parse.User.current().get("network")
        @$('#network-nav').addClass("dropdown").html JST["src/js/templates/user/nav_menu_network.jst"](i18nCommon: i18nCommon)
      else
        @$('#network-nav').removeClass("dropdown").html "<a href='/inside'>#{i18nCommon.nouns.inside}</a>"# #{i18nCommon.verbs.manage}

      # Panel.
      $('#panel-home-nav a').html i18nCommon.nouns.outside # i18nCommon.verbs.explore
      $('#panel-network-nav a').html i18nCommon.nouns.inside # #{i18nCommon.verbs.manage}
      $('#panel-following-nav a').html i18nCommon.nouns.following # #{i18nCommon.verbs.manage}

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
