define [
  'jquery',
  'underscore',
  'backbone',
  'models/Location'
], ($, _, Parse, Location) ->

  class LocationList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Location

    query: new Parse.Query(Location).include("profile")

    closestNeighbourhoodAndLocation: (GeoPoint) ->
      components = {}
      # Must be within 50 km
      kilometersCity = 50
      kilometersNeighbourhood = 50
      @each (l) =>
        if l.get("isCity")
          if components.location
            if GeoPoint.kilometersTo(l.get("center")) < kilometersCity
              components.location = l
              kilometersCity = GeoPoint.kilometersTo components.location.get("center")
          else 
            components.location = l
        else
          if components.neighbourhood
            if GeoPoint.kilometersTo(l.get("center")) < kilometersNeighbourhood
              components.neighbourhood = l
              kilometersNeighbourhood = GeoPoint.kilometersTo components.neighbourhood.get("center")
          else 
            components.neighbourhood = l

      if components.neighbourhood then components.neighbourhood = components.neighbourhood._toPointer()
      if components.location then components.location = components.location._toPointer()
            
      components