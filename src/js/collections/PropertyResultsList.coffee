define [
  'jquery',
  'underscore',
  'backbone',
  'models/Property'
], ($, _, Parse, Property) ->

  class PropertyResultsList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Property

    query: new Parse.Query("Property")

    initialize: (models, attrs) ->

      @forNetwork = attrs.forNetwork

      if Parse.User.current()
        @query.notEqualTo "objectId", Parse.User.current().get("property").id if Parse.User.current().get("property")
        @query.notEqualTo "network", Parse.User.current().get("network") if Parse.User.current().get("network")

      @query.doesNotExist "network" if attrs.forNetwork

    setCenter: (center) -> @query.near "center", center