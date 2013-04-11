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
      @createQuery(attrs.lease) if attrs and attrs.lease and attrs.lease.id
      
    createQuery: (lease) ->
      @lease = lease if lease
      if @lease and @lease.id      
        @query = new Parse.Query(Tenant)
        .equalTo("lease", @lease)
        .include("profile")