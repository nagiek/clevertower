define [
  'jquery'
  'underscore'
  'backbone'
  'models/Listing'
], ($, _, Parse, Listing) ->

  class ListingList extends Parse.Collection

    model: Listing    
      
    initialize: (models, attrs) ->

      # We load ListingList before Parse is initialized, so we cannot pre-load the query.
      @query = new Parse.Query(Listing).include("unit").descending("createdAt")

      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.unit
        @unit = attrs.unit
        @query.equalTo "unit", @unit
      else 
        @network = attrs.network
        @query.equalTo "network", @network
      
    comparator = (listing) -> listing.get("rent")