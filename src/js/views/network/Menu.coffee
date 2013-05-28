define [
  "jquery"
  "underscore"
  "backbone"
  'models/Network'
  "i18n!nls/common"
], ($, _, Parse, Network, i18nCommon) ->

  class NetworkMenuView extends Parse.View

    el: "#domain-menu"
    
    initialize: ->

      Parse.Dispatcher.on "user:logout", ->
        delete @model
    
    initModel : ->
      @model = Parse.User.current().get("network")
      @listenTo @model, "change", @render
      
    render: =>  
      if Parse.User.current() and Parse.User.current().get("network")
        @initModel()
        
      @$('#home-nav a').html i18nCommon.verbs.explore

      hostArray = location.host.split(".")
      if hostArray.length > 2
        # On a subdomain
        hostArray.shift()
        @$('#home-nav a').prop "href", '//' + hostArray.join(".")
        @$('#network-nav').html if Parse.User.current() then "<a href='/'>#{i18nCommon.verbs.manage}</a>" else ''
      else
        # On main domain
        if Parse.User.current()
          # Set the link to the network subdomain.
          href = if @model then @model.privateUrl() else "/account/setup"
          @$('#network-nav').html "<a href='#{href}'>#{i18nCommon.verbs.manage}</a>"
        else
          @$('#network-nav').html ""
      @
