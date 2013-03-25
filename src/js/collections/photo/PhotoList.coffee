define [
  'jquery',
  'underscore',
  'backbone',
  'models/Photo'
], ($, _, Parse, Photo) ->

  class PhotoList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Photo