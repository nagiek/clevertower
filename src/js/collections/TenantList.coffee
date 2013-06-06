define [
  'jquery',
  'underscore',
  'backbone',
  'models/Tenant'
], ($, _, Parse, Tenant) ->

  class TenantList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Tenant

    initialize: (models, attrs) ->
      @lease = attrs.lease
      @network = attrs.network
      @property = attrs.property
      @profile = attrs.profile
      @createQuery()

    createLeaseQuery: (lease) ->
      @lease = lease
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
      @query = new Parse.Query(Tenant).include("profile")
      if @lease and @lease.id     then @query.equalTo("lease", @lease)
      if @property and @property.id then @query.equalTo("property", @property)
      if @network and @network.id then @query.equalTo("network", @network)
      if @profile and @profile.id 
        @query.equalTo("profile", @profile)
        .include("lease.unit")
        .include("property")

    filterRecent : (conditions) ->      
      d = new Date()
      d.setDate(d.getDate()-31);
      @filter (t) -> 
        filterconditions = if conditions then _.each conditions, (c, i) -> t[i] is c else true 
        return t.createdAt > d and filterconditions
