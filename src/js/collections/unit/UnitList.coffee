define [
  'jquery',
  'underscore',
  'backbone',
  'models/Unit'
], ($, _, Parse, Unit) ->

  class UnitList extends Parse.Collection

    # Reference to this collection's model.
    model: Unit
    
    initialize: (attrs) ->
      @property = attrs.property

    url:  ->
      "/properties/#{@property.get "id"}/units"

    # query: ->
    #   query = new Parse.Query(Unit)
    #   query.equalTo "property", @property
    #   query
      
    comparator = (unit) ->
      title = unit.get "title"
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title