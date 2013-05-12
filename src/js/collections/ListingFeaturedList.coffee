define [
  'jquery',
  'underscore',
  'backbone',
], ($, _, Parse) ->

  class FeaturedListingList extends Parse.Collection

    # model: Listing
    
    # query: new Parse.Query("Listing")
    query: new Parse.Query("FeaturedListing")
            .include("property")
            .descending("createdAt")
             # .near("center", @location)



