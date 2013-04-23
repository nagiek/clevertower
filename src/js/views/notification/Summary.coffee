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
      'click > a' : 'markAsClicked'
        
    initialize: ->
      @model.on "change", @render
        
    markAsClicked: (e) =>

      @model.add(clicked: [Parse.User.current()])
      @model.save null, patch: true
  
    # Re-render the contents of the property item.
    render: =>
      channels = @model.get "channels"
      network = @model.get "network"
      property = @model.get "property"
      profile = @model.get "profile"
      event = @model.get "name" 
      name = profile.name()
      
      if @model.get "forMgr"
        url = ""
        url += "//#{Parse.User.current().get("network").get("name")}.#{location.host}" if location.host.split(".").length is 2
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
      

      text = i18nCommon.notifications.text[event](name, property.get("title"))

      vars = 
        age: moment(@model.createdAt).fromNow()
        text: text
        url: url
        clicked: _.contains @model.get("clicked"), Parse.User.current()
        icon: icon
        photo_src: photo_src
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/notification/summary.jst"](vars)
      @