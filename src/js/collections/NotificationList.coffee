define [
  'jquery',
  'underscore',
  'backbone',
  'models/Notification'
  'models/Property'
], ($, _, Parse, Notification, Property) ->

  class NotificationList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Notification

    initialize: ->

      channels = ["profiles-#{Parse.User.current().get('profile').id}"]
      channels.push "networks-#{Parse.User.current().get('network').id}" if Parse.User.current().get('network')
      channels.push "properties-#{Parse.User.current().get('property').id}" if Parse.User.current().get('property')

      # LOL WTF.
      @query = new Parse.Query(Notification)
                .containedIn("channels", channels)
                .include('network') # For mgr invitations.
                .include('property.profile')
                .include('profile')
                .include('tenant')
                .include('unit')
                .include('lease')
                .include('manager')
                .descending("createdAt")
                .limit(6) 

    comparator: (n) -> -n.createdAt

    # Filter down the list of all todo items that are finished.
    unread: => @filter (n) -> n.unread() 
    unclicked: => @filter (n) -> n.unclicked()

    # Divide the notifications into two types: those that have actions and those that do not.
    memos: => @filter (n) -> n.isMemo()
    withAction: => @filter (n) -> !n.isMemo()

    # Underscore doesn't want to chain our custom functions :(
    unreadMemos: => @filter (n) -> n.isMemo() and n.unread()
    unreadWithAction: => @filter (n) -> !n.isMemo() and n.unread()
    visibleWithAction: => @filter (n) -> !n.isMemo() and !n.hidden()