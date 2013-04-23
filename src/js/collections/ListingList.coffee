define [
  'jquery',
  'underscore',
  'backbone',
  'models/Listing'
], ($, _, Parse, Listing) ->

  class ListingList extends Parse.Collection

    model: Listing
    query: new Parse.Query("Listing").include("unit")
      
    initialize: (models, attrs) ->
      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.unit
        @unit = attrs.unit
        @query.equalTo "unit", @unit

    # Filter down the list of all active listings
    active: ->
      @filter (listing) ->
        listing.isActive()

    # Filter down the list of all inactive listings
    inactive: ->
      @without.apply this, @active()

    # query: ->
    #   query = new Parse.Query(Listing)
    #   query.equalTo "property", @property
    #   query
      
    comparator = (listing) ->
      title = listing.get("unit").get("title")
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title