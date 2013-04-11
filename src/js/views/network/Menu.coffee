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
      
      if Parse.User.current()
      
        Parse.User.current().on "user:login", ->
          @networkQuery()  
      
        Parse.User.current().on "user:logout", ->
          delete @model

        if Parse.User.current().get("network")
          @initModel(Parse.User.current())
        else
          @networkQuery()
      else
        @render()
              
    networkQuery : ->
      (new Parse.Query("_User")).equalTo("objectId", Parse.User.current().id).include('network.role').first()
      .then (user) =>
        if user and user.get("network")
          @initModel(user) 
        else
          @render()
    
    initModel : (user) ->
      @model = user.get "network"
      @model.on "change", @render
      @render()
      
    render: ->  
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
