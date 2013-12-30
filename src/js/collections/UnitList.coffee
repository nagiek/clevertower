define [
  'jquery',
  'underscore',
  'backbone',
  'models/Unit'
  'models/Lease'
], ($, _, Parse, Unit, Lease) ->

  class UnitList extends Parse.Collection

    # Reference to this collection's model.
    model: Unit
    
    initialize: (models, attrs) ->
      
      @query = new Parse.Query(Unit).include("activeLease")

      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.network
        @network = attrs.network
        @query.equalTo "network", @network
      
    comparator: (unit) ->
      title = unit.get "title"
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title
    
    # We may not have a @property, so be specific.
    prepopulate: (property) =>
      units = @select((u) -> u.get("property").id is property.id)
      if units.length is 0 then unit = new Unit property: property, profile: property.get("profile")
      else 
        
        unit = _.last(units).clone()
        unit.unset "activeLease"
        
        title = unit.get 'title'
        newTitle = title.substr 0, title.length-1
        char = title.charAt title.length - 1
        # Convert to string for Parse DB
        newChar = if isNaN(char) then String.fromCharCode char.charCodeAt() + 1 else String Number(char) + 1
        unit.set 'title', newTitle + newChar
      @add unit
      