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

    query: new Parse.Query("Notification")
          .include('property')
          .include('profile')
          .descending("createdAt")
          # .equalTo("user", Parse.User.current())
          .limit(6) 
      
    comparator: (notification) -> -notification.createdAt

    # Filter down the list of all todo items that are finished.
    unread: -> @filter (notification) -> if notification.get "read" then false else true
    unclicked: -> @filter (notification) -> if notification.get "clicked" then false else true
