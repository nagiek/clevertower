define [
  "jquery"
  "underscore"
  "backbone"
  'models/Network'
  "i18n!nls/common"
], ($, _, Parse, Network, i18nCommon) ->

  class NetworkMenuView extends Parse.View

    el: "#network-nav"
    
    initialize: ->
      _.bindAll this, "render"

      Parse.Dispatcher.on "user:logout", ->
        delete @model
    
    initModel :->
      @model = Parse.User.current().get("network")
      @model.on "change", @render
      
    render: ->  
      if Parse.User.current() and Parse.User.current().get("network")
        @initModel()
        
      hostArray = location.host.split(".")
      if hostArray.length > 2
        # On a subdomain
        hostArray.shift()
        $('#home-nav a').prop "href", hostArray.join(".")
        @$el.html if Parse.User.current() then "<a href='/'>#{i18nCommon.classes.Network}</a>" else ''
      else
        # On main domain
        if Parse.User.current()
          # Set the link to the network subdomain.
          href = if @model then "#{location.protocol}//#{@model.get("name")}.#{location.host}" else "/network/set"
          @$el.html "<a href='#{href}'>#{i18nCommon.classes.Network}</a>"
        else
          @$el.html ""
      @
