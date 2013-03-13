define [
  'jquery',
  'underscore',
  'backbone',
  'models/Photo'
], ($, _, Parse, Photo) ->

  class PhotoList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Photo
  
    # Filter down the list of all Photo items that are finished.
    done: ->
      @filter (Photo) ->
        Photo.get "done"

  
    # Filter down the list to only Photo items that are still not finished.
    remaining: ->
      @without.apply this, @done()

  
    # We keep the Photos in sequential order, despite being saved by unordered
    # GUID in the database. This generates the next order number for new items.
    nextOrder: ->
      return 1  unless @length
      @last().get("order") + 1

  
    # Photos are sorted by their original insertion order.
    comparator: (Photo) ->
      Photo.get "order"