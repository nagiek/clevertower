define [
  'jquery',
  'underscore',
  'backbone',
  'models/Listing'
], ($, _, Parse, Listing) ->

  class FeedListingList extends Parse.Collection

    model: Listing
    query: new Parse.Query("Listing")
            .include("property")
            .descending("createdAt")
             # .near("center", @location)

    initialize: (models, attrs) ->
      @query.greaterThanOrEqualTo("rent", attrs.min).lessThanOrEqualTo("rent", attrs.max)



