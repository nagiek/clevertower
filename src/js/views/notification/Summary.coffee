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
      'click' : 'markAsRead'
        
    initialize: ->
      @model.on "change", @render
        
    markAsRead: (e) =>
      @model.set "read", true
      @model.save()
  
    # Re-render the contents of the property item.
    render: =>
      channels = @model.get "channels"
      property = @model.get "property"
      user = @model.get "user"
      event = @model.get "name" 
      name = if user.get("name") then user.get("name") else user.get "email"
      
      url = "/" + channels[0].replace("-", "/")
      url = "/properties/#{property.id}" + url unless channels[0].indexOf('properties') is 0
      
      switch channels[0].split("-")[0]
        when 'properties'
          icon = 'person'
          photo_src = property.cover("thumb")
        when 'leases' or 'tenant'
          icon = 'plus'
          photo_src = user.cover("thumb")
        else 
          icon = 'calendar'
          photo_src = user.cover("thumb")
      
      vars = _.merge(
        age: moment(@model.createdAt).fromNow()
        text: i18nCommon.notifications.text[event](name, property.get("thoroughfare"))
        url: url
        read: @model.get "read"
        icon: icon
        photo_src: photo_src
        i18nCommon: i18nCommon
      )
      @$el.html JST["src/js/templates/notification/summary.jst"](vars)
      @