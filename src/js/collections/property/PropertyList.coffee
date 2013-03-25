define [
  'jquery',
  'underscore',
  'backbone',
  'models/Property'
], ($, _, Parse, Property) ->

  class PropertyList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Property

    url: ->
      "/"