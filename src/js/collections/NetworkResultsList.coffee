define [
  'jquery',
  'underscore',
  'backbone',
  'models/Network'
], ($, _, Parse, Network) ->

  class NetworkResultsList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Network

    query: new Parse.Query("Network")

    initialize: (models, attrs) ->
      if Parse.User.current() and Parse.User.current().get("network")
        @query.notEqualTo "network", Parse.User.current().get("network")

    setName: (name) -> @query.equalTo "name", name