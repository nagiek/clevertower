define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Activity = Parse.Object.extend "Activity",
  
    className: "Activity"