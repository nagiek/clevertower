define [
  'jquery',
  'underscore',
  'backbone',
  'models/Photo'
], ($, _, Parse, Photo) ->

  class PhotoList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Photo

    query: new Parse.Query("Photo")

    initialize: (models, attrs) ->
      # We load PropertyList before Parse is initialized, so we cannot pre-load the query.
      @query.equalTo("property", attrs.property) if attrs.property