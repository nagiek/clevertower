define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Notification'
  'models/Property'
  "i18n!nls/common"
  'templates/notification/tablerow',
], ($, _, Parse, moment, Notification, Property, i18nCommon) ->

  class NotificationSetupView extends Parse.View
  
    tagName: "tr"
  
    events:
      'click a.unclicked' : 'handleClick'
      'click .accept' : 'accept'
      'click .ignore' : 'ignore'
      'click .undo' : 'undo'
        
    initialize: ->
      @listenTo Parse.Dispatcher, "user:logout", @clear

    handleClick : =>
      @$("> a").removeClass "unclicked"
      @markAsClicked()

    accept: (e) =>
      actionItem = if @model.get("tenant") then @model.get("tenant") else @model.get("manager")
      return unless actionItem
      @model.add hidden: [Parse.User.current().id]
      @markAsClicked()
      @$(".photo-float").html "<div>" + @model.accepted() + "</div>"
      @$(".btn-toolbar").hide()

      # Until req.object.original lands for Cloud Code, have to pass in new status.
      actionItem.save(newStatus: "current").then =>
        if @model.className is "Tenant" 
          Parse.User.current().set
            property: @model.get("property")
            unit: @model.get("unit")
            lease: @model.get("lease")
        else if @model.className is "Manager" then Parse.User.current().set("network", @model.get("network"))

    ignore: (e) =>
      # Don't modify the action item, just hide the request.
      @$(".photo-float").html "<div>" + @model.ignored() + "</div><small>(<a href='#' class='undo'>" + i18nCommon.actions.undo + "</a>)</small>"
      @$(".btn-toolbar").hide()
      @model.add hidden: [Parse.User.current().id]
      @model.save null, patch: true

    undo: (e) =>
      # Don't modify the action item, just hide the request.
      @model.remove hidden: [Parse.User.current().id]
      @model.save null, patch: true
      @render()
  
    markAsClicked: (e) =>
      @model.add clicked: [Parse.User.current().id]
      @model.save null, patch: true


    render: =>
      channels = @model.get "channels"
      network = @model.get "network"
      subject = @model.get "subject"
      object = @model.get "object"

      if @model.get "forMgr"
        url = ""
        url += "/properties/#{property.id}" if property
        url += channels[0].replace("-", "/") unless channels[0].indexOf('properties') or channels[0].indexOf('profiles')
      else
        url = "/" + channels[0].replace("-", "/")

      switch channels[0].split("-")[0]
        when 'properties'
          icon = 'person'
          photo_src = property.cover("thumb")
        when 'leases' or 'tenant'
          icon = 'plus'
          photo_src = subject.cover("thumb")
        else 
          icon = 'calendar'
          photo_src = subject.cover("thumb")

      vars = 
        timeAgo: moment(@model.createdAt).fromNow()
        text: @model.text()
        url: url
        clicked: _.contains @model.get("clicked"), Parse.User.current().id
        icon: icon
        photo_src: photo_src
        i18nCommon: i18nCommon
        withAction: !@model.isMemo()
        permanent: false

      @$el.html JST["src/js/templates/notification/tablerow.jst"](vars)
      @

    clear: =>
      @remove()
      @undelegateEvents()
      delete this