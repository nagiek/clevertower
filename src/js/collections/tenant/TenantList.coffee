define [
  'jquery',
  'underscore',
  'backbone',
  'models/Tenant'
], ($, _, Parse, Tenant) ->

  class TenantList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Tenant

