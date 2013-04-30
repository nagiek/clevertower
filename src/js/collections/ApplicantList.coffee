define [
  'jquery',
  'underscore',
  'backbone',
  'models/Applicant'
], ($, _, Parse, Applicant) ->

  class ApplicantList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Applicant

    initialize: (models, attrs) ->
      @inquiry = attrs.inquiry
      @listing = attrs.listing
      @property = attrs.property
      @network = attrs.network
      @profile = attrs.profile
      @createQuery()

    createInquiryQuery: (inquiry) ->
      @inquiry = inquiry
      @createQuery()
              
    createListingQuery: (listing) ->
      @listing = listing
      @createQuery()

    createPropertyQuery: (property) ->
      @property = property
      @createQuery()

    createNetworkQuery: (network) ->
      @network = network
      @createQuery()

    createProfileQuery: (profile) ->
      @profile = profile
      @createQuery()
              
    createQuery: ->
      @query = new Parse.Query(Applicant).descending("createdAt").include("profile")

      # Coming from Network perspective
      if @inquiry and @inquiry.id then @query.equalTo("inquiry", @inquiry)
      if @listing and @listing.id then @query.equalTo("listing", @listing)
      if @property and @property.id then @query.equalTo("property", @property)
      if @network and @network.id then @query.equalTo("network", @network)

      if @profile 
        # Coming from Public perspective

        innerQuery = new Parse.Query Applicant
        innerQuery.equalTo("profile", @profile)
        # innerQuery.include("profile").include("inquiry")

        @query
        .matchesKeyInQuery("inquiry", "inquiry", innerQuery)
        .include("inquiry.listing")
        .include("inquiry.property")


