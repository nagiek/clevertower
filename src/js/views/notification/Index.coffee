define [
  "jquery"
  "underscore"
  "backbone"
  'collections/NotificationList'
  'models/Notification'
  'views/notification/Summary'
  "i18n!nls/common"
], ($, _, Parse, NotificationList, Notification, NotificationView, i18nCommon) ->

  class NotificationIndexView extends Parse.View
  
    el: "#notifications"

    events:
      'click #nLabel' : 'markAllAsRead'
        
    initialize: (attrs) ->

      Parse.User.current().notifications = new NotificationList unless Parse.User.current().notifications

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @listenTo Parse.User.current().notifications, "add", @addOne
      @listenTo Parse.User.current().notifications, "reset", @addAll
      
      
    markAllAsRead: =>
      _.each Parse.User.current().notifications.unread(), (n) -> 
        n.add(read: [Parse.User.current()])
        n.save null, patch: true

    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: =>
      Parse.User.current().notifications.fetch()
        
      @$list = @$('ul')
      @$count = @$('#notifications-count')

      @
    
    clear: (e) =>
      @stopListening()
      @undelegateEvents()
      delete this
    
    # Add all items in the notifications collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      Parse.User.current().notifications.each @addOne
      if Parse.User.current().notifications.length is 0 then @$list.html '<li class="empty">' + i18nCommon.notifications.empty + '</li>'

      size = Parse.User.current().notifications.unread().length
      @$count.html size
      if size > 0 then @$count.addClass("badge-important") else @$count.removeClass("badge-important")

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (notification) =>
      @$('li.empty').hide()
      view = new NotificationView(model: notification)
      @$list.append view.render().el