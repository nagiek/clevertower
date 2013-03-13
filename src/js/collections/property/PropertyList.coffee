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
      "/properties"
  
    # Filter down the list of all Property items that are finished.
    done: ->
      @filter (Property) ->
        Property.get "done"

  
    # Filter down the list to only Property items that are still not finished.
    remaining: ->
      @without.apply this, @done()

  
    # We keep the Propertys in sequential order, despite being saved by unordered
    # GUID in the database. This generates the next order number for new items.
    nextOrder: ->
      return 1  unless @length
      @last().get("order") + 1

  
    # Propertys are sorted by their original insertion order.
    comparator: (Property) ->
      Property.get "order"