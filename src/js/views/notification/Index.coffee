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
  
    el: "#user-menu"

    events:
      # Despite the names, "read" means "seen", and "clicked" means "read"
      'click #mark-read' : 'markMemosAsClicked'
      'click #mLabel'    : 'markMemosAsRead'
      'click #fLabel'    : 'markWithActionsllAsRead'
        
    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @listenTo Parse.User.current().notifications, "add", @addOne
      @listenTo Parse.User.current().notifications, "reset", @addAll
      
    markMemosAsClicked: (e) =>
      e.preventDefault()
      e.stopPropagation()
      unclickedMemos = Parse.User.current().notifications.unclickedMemos()
      _.each unclickedMemos, (n) -> n.add(clicked: [Parse.User.current().id])
      Parse.Object.saveAll unclickedMemos

    markMemosAsRead: =>
      @$mCount.html(0).addClass("hide")
      unreadMemos = Parse.User.current().notifications.unreadMemos()
      _.each unreadMemos, (n) -> n.add(read: [Parse.User.current().id])
      Parse.Object.saveAll unreadMemos

    markWithActionsllAsRead: =>
      @$fCount.html(0).addClass("hide")
      unreadActions = Parse.User.current().notifications.withAction()
      _.each unreadActions, (n) -> n.add(read: [Parse.User.current().id])
      Parse.Object.saveAll unreadActions

    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: =>
        
      @$mList = @$('#memos ul')
      @$mCount = @$('#memos-count')
      @$fList = @$('#friend-requests ul')
      @$fCount = @$('#friend-requests-count')
      
      @addAll()

      @
    
    clear: (e) =>
      @stopListening()
      @undelegateEvents()
      delete this
    
    # Add all items in the notifications collection at once.
    addAll: (collection, filter) =>

      @$mList.html ''
      @$fList.html ''
      Parse.User.current().notifications.each @addOne
      if Parse.User.current().notifications.memos().length is 0
        @$mList.html '<li class="empty">' + i18nCommon.notifications.empty.memo + '</li>'
      if Parse.User.current().notifications.visibleWithAction().length is 0
        @$fList.html '<li class="empty">' + i18nCommon.notifications.empty.withAction + '</li>'


      mSize = Parse.User.current().notifications.unreadMemos().length
      @$mCount.html mSize
      if mSize > 0 then @$mCount.removeClass("hide") else @$mCount.addClass("hide")

      # Display all with action. They're important.
      fSize = Parse.User.current().notifications.unreadWithAction().length
      @$fCount.html fSize
      if fSize > 0 then @$fCount.removeClass("hide") else @$fCount.addClass("hide")

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (n) =>
      view = new NotificationView(model: n)
      unless n.hidden()
        if n.isMemo()
          @$mList.find('li.empty').remove()
          @$mList.append view.render().el
        else 
          @$fList.find('li.empty').remove()
          @$fList.append view.render().el