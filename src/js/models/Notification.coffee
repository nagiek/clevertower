define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Notification = Parse.Object.extend "Notification",

    defaults:
      read         : false
