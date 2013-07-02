define [
  'jquery',
  'underscore',
  'backbone',
  'models/Property'
  'gmaps'
], ($, _, Parse, Property) ->

  class PropertyList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Property

    query: new Parse.Query("Property")

    GPoint : -> new google.maps.LatLng @center._latitude ,@center._longitude
    center: new Parse.GeoPoint 43.6481, -79.4042
    radius: 15000

    initialize: (models, attrs) ->
      # We load PropertyList before Parse is initialized, so we cannot pre-load the query.
      @query.equalTo("network", attrs.network) if attrs and attrs.network

    getSetting: ->
      if @length > 0
        centers = @map (p) -> p.get("center")
        hiLat = loLat = centers[0]._latitude
        hiLng = loLng = centers[0]._longitude
        _.each centers, (c) ->       
          hiLat = Math.max c._latitude, hiLat;  loLat = Math.min c._latitude, loLat
          hiLng = Math.max c._longitude, hiLng; loLng = Math.min c._longitude, loLng

        lat = (loLat + hiLat)/2
        lng = (loLng + hiLng)/2
        @center = new Parse.GeoPoint lat, lng

        rLat = if Math.abs(hiLat - lat) > Math.abs(loLat - lat) then hiLat else loLat
        rLng = if Math.abs(hiLng - lng) > Math.abs(loLng - lng) then hiLng else loLng
        @radius = @getDistanceFromLatLngInKm rLat, rLng
        # @radius = Math.max (hiLat - loLat)/2, (hiLng - loLng)/2, 15000 # At least 15 km view.

      # else
      #   @center = new Parse.GeoPoint 45, -78
      #   @radius = 15000
      
    # Helper function
    # average: (ary) ->
    #   tot = 0
    #   tot += arg for arg in ary
    #   tot / ary.length

    getDistanceFromLatLngInKm : (lat,lng) ->
      R = 6371000 # m

      dLat = @deg2rad(lat-@center._latitude)
      dLon = @deg2rad(lng-@center._longitude)

      a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.sin(dLon/2) * Math.sin(dLon/2) * 
          Math.cos(@deg2rad(@center._latitude)) * Math.cos(@deg2rad(lat))
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      R * c

    deg2rad : (deg) -> deg * (Math.PI/180)