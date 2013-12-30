define [
  'jquery',
  'underscore',
  'backbone',
  'models/Inquiry'
], ($, _, Parse, Inquiry) ->

  class InquiryList extends Parse.Collection

    model: Inquiry
      
    initialize: (models, attrs) ->
      
      @query = new Parse.Query("Inquiry").descending("createdAt")

      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.network
        @network = attrs.network
        @query.equalTo "network", @network
      else if attrs.unit
        @unit = attrs.unit
        @query.equalTo "unit", @unit
      else if attrs.listing
        @listing = attrs.listing
        @query.equalTo "listing", @listing
      
    comparator: (inquiry) -> inquiry.createdAt