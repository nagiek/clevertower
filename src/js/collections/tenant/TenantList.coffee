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
      
    createQuery: ->
      @query = new Parse.Query(Tenant).include("profile")
      if @lease and @lease.id     then @query.equalTo("lease", @lease)
      if @property and @property.id then @query.equalTo("property", @property)
      if @network and @network.id then @query.equalTo("network", @network)