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
      @property = attrs.property
      # today = new Date
      # innerQuery = new Parse.Query(Lease)
      # innerQuery.equalTo "property", @property
      # innerQuery.lessThan "start_date", today
      # innerQuery.greaterThan "end_date", today
      
      @query = new Parse.Query(Unit)
      .equalTo("property", @property)
      .include("activeLease")


    url:  ->
      "/properties/#{@property.get "id"}/units"
      
    comparator: (unit) ->
      title = unit.get "title"
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title
        
    prepopulate: =>
      if @length is 0 then unit = new Unit property: @property 
      else 
        unit = @at(@length - 1).clone()

        unit.set "has_lease", false
        unit.unset "activeLease"
        
        title = unit.get 'title'
        newTitle = title.substr 0, title.length-1
        char = title.charAt title.length - 1
        # Convert to string for Parse DB
        newChar = if isNaN(char) then String.fromCharCode char.charCodeAt() + 1 else String Number(char) + 1
        unit.set 'title', newTitle + newChar
      @add unit
      