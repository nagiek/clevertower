define [
  'jquery',
  'underscore',
  'backbone',
  'models/Listing'
], ($, _, Parse, Listing) ->

  class ListingList extends Parse.Collection

    model: Listing
    query: new Parse.Query("Listing").include("unit").descending("createdAt")
      
    initialize: (models, attrs) ->
      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.unit
        @unit = attrs.unit
        @query.equalTo "unit", @unit
      
    comparator = (listing) -> listing.get("rent")