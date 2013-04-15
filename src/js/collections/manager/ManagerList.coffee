define [
  'jquery',
  'underscore',
  'backbone',
  'models/Manager'
], ($, _, Parse, Manager) ->

  class ManagerList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Manager

    initialize: (models, attrs) ->
      @createQuery(attrs.network) if attrs and attrs.network and attrs.network.id
      
    createQuery: (network) ->
      @network = network if network
      if @network and @network.id      
        @query = new Parse.Query(Manager)
        .equalTo("network", @network)
        .include("profile")