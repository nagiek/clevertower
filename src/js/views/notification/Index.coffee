define [
  "jquery"
  "underscore"
  "backbone"
  'collections/notification/NotificationList'
  'models/Notification'
  'views/notification/Summary'
  "i18n!nls/common"
], ($, _, Parse, NotificationList, Notification, NotificationView, i18nCommon) ->

  class NotificationIndexView extends Parse.View
  
    el: "#notifications"
        
    initialize: (attrs) ->
      @editing = false
      
      Parse.Dispatcher.on "user:logout", @clear

      @notifications = new NotificationList
      @notifications.on "add", @addOne
      @notifications.on "reset", @addAll
      @notifications.on "all", @render
      
      @notifications.fetch()
        
      @$list = @$('ul')
      @$count = @$('#notifications-count')

        # success: (collection, response, options) =>
        #   @notifications.add [{property: @model}] if collection.length is 0
                
    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: =>
      size = @notifications.unread().length
      @$count.html size
      if size > 0 then @$count.addClass("badge-important") else @$count.removeClass("badge-important")
      @
    
    clear: (e) =>
      @undelegateEvents()
      delete this
    
    # Add all items in the notifications collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      @notifications.each @addOne
      if @notifications.length is 0 then @$list.html '<li class="empty">' + i18nCommon.notifications.empty + '</li>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (notification) =>
      @$('li.empty').hide()
      view = new NotificationView(model: notification)
      @$list.append view.render().el