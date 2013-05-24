define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Activity = Parse.Object.extend "Activity",
  
    className: "Activity"

    GPoint : -> new google.maps.LatLng @get("center")._latitude, @get("center")._longitude

    # Index of model in its collection.
    pos : -> @collection.indexOf(@)