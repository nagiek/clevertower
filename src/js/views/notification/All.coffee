define [
  "jquery"
  "underscore"
  "backbone"
  'collections/NotificationList'
  'models/Notification'
  'views/notification/TableRow'
  "i18n!nls/common"
], ($, _, Parse, NotificationList, Notification, NotificationView, i18nCommon) ->

  class AllNotificationView extends Parse.View
  
    el: "#main"
        
    initialize: (attrs) ->

      @notifications = new NotificationList
      @notifications.query.limit(-1)

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @listenTo @notifications, "add", @addOne
      @listenTo @notifications, "reset", @addAll

    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: =>

      @$el.html """
                <div class="container">
                  <h1>#{i18nCommon.classes.notifications}</h1>
                  <table class="table content"><tbody></tbody></table>
                </div>
                """
      @$list = @$('table.content tbody')

      # @notifications.add Parse.User.current().notifications.models
      @notifications.fetch()
      @
    
    clear: (e) =>
      @stopListening()
      @undelegateEvents()
      delete this
    
    # Add all items in the notifications collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      
      if @notifications.length is 0
        @$list.html '<tr class="empty"><td>' + i18nCommon.notifications.empty.all + '</td></tr>'
      else 
        @$list.find('tr.empty').remove()
        @notifications.each @addOne

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (n) =>
      view = new NotificationView(model: n)
      @$list.append view.render().el
