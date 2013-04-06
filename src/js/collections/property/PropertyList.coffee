define [
  'jquery',
  'underscore',
  'backbone',
  'models/Property'
], ($, _, Parse, Property) ->

  class PropertyList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Property

    initialize: ->
      # We load PropertyList before Parse is initialized, so we cannot pre-load the query.
      @query = new Parse.Query("Property").equalTo("user", Parse.User.current())