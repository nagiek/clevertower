define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Notification'
  'models/Property'
  "i18n!nls/common"
  'templates/notification/summary',
], ($, _, Parse, moment, Notification, Property, i18nCommon) ->

  class NotificationSummaryView extends Parse.View
  
    tagName: "li"
  
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
      @render()

      # Until req.object.original lands for Cloud Code, have to pass in new status.
      actionItem.save(newStatus: "current").then ->
        if @model.className is "Tenant" 
          Parse.User.current().set
            property: @model.get("property")
            unit: @model.get("unit")
            lease: @model.get("lease")
        else if @model.className is "Manager" then Parse.User.current().set("network", @model.get("network"))

    ignore: (e) =>
      # Don't modify the action item, just hide the request.
      @model.add hidden: [Parse.User.current().id]
      @model.save null, patch: true
      @render()

    undo: (e) =>
      # Don't modify the action item, just hide the request.
      @model.remove hidden: [Parse.User.current().id]
      @model.save null, patch: true
      @render()
  
    markAsClicked: (e) =>
      @model.add clicked: [Parse.User.current().id]
      @model.save null, patch: true
  
    # Re-render the contents of the property item.
    render: =>
      clicked = _.contains @model.get("clicked"), Parse.User.current().id
      hidden = _.contains @model.get("hidden"), Parse.User.current().id

      channels = @model.get "channels"
      network = @model.get "network"
      property = @model.get "property"
      profile = @model.get "profile"

      if @model.get "forMgr"
        url = ""
        # url += "//#{Parse.User.current().get("network").get("name")}.#{location.host}" if location.host.split(".").length is 2
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
          photo_src = profile.cover("thumb")
        else 
          icon = 'calendar'
          photo_src = profile.cover("thumb")

      if clicked
        text = @model.accepted()
      else if hidden
        text = @model.ignored() + "<small>(<a href='#' class='undo'>" + i18nCommon.actions.undo + "</a>)</small>"
      else
        text = @model.text()

      vars = 
        timeAgo: moment(@model.createdAt).fromNow()
        text: text
        url: url
        clicked: clicked
        icon: icon
        photo_src: photo_src
        i18nCommon: i18nCommon
        withAction: !@model.isMemo()

      @$el.html JST["src/js/templates/notification/summary.jst"](vars)
      @

    clear: =>
      @remove()
      @undelegateEvents()
      delete this