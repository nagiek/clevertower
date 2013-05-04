define [
  'jquery',
  'underscore',
  'backbone',
  'models/Listing'
], ($, _, Parse, Listing) ->

  class FeedListingList extends Parse.Collection

    model: Listing
    query: new Parse.Query("Listing").include("property").descending("createdAt") # .near("center", @location)



      