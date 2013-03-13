define [
  'jquery',
  'underscore',
  'backbone',
  'models/Unit'
], ($, _, Parse, Unit) ->

  class UnitList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Unit

    url: ->
      "/properties/#{property.get "id"}/units"
  
    # Filter down the list of all Unit items that are finished.
    done: ->
      @filter (Unit) ->
        Unit.get "done"

  
    # Filter down the list to only Unit items that are still not finished.
    remaining: ->
      @without.apply this, @done()

  
    # We keep the Units in sequential order, despite being saved by unordered
    # GUID in the database. This generates the next order number for new items.
    nextOrder: ->
      return 1  unless @length
      @last().get("order") + 1

  
    # Units are sorted by their original insertion order.
    comparator: (Unit) ->
      Unit.get "order"