define [
  'underscore',
  'backbone',
  "collections/unit/UnitList"
  "models/Unit"
], (_, Parse, UnitList, Unit) ->

  Property = Parse.Object.extend "Property"
  # class Property extends Parse.Object
    
    className: "Property"

    defaults:
      # Location
      center                        : new Parse.GeoPoint
      formatted_address             : ''
      address_components            : []
      location_type                 : "APPROXIMATE"
      thoroughfare                  : ''
      locality                      : ''
      neighbourhood                 : ''
      administrative_area_level_1   : ''
      administrative_area_level_2   : ''
      country                       : ''
      postal_code                   : ''
      
      # Images
      image_thumb         : ""
      image_profile       : ""
      image_full          : ""

      # Attributes
      description         : ""
      phone               : ""
      email               : ""
      website             : ""
      title               : ""
      property_type       : ""
      year                : ""
      mls                 : ""
      
      # Booleans
      air_conditioning    : false
      back_yard           : false
      balcony             : false
      cats_allowed        : false
      concierge           : false
      dogs_allowed        : false
      doorman             : false
      elevator            : false
      exposed_brick       : false
      fireplace           : false
      front_yard          : false
      gym                 : false
      laundry             : false
      indoor_parking      : false
      outdoor_parking     : false
      pool                : false
      sauna               : false
      wheelchair          : false
      electricity         : false
      furniture           : false
      gas                 : false
      heat                : false
      hot_water           : false
      
      # Private
      init                : false
      public              : false

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/property-#{format}.png" if img is ''
      img 

    loadUnits: ->
      unless @units          
        @units = new UnitList property: @model
        # @units.query = new Parse.Query(Unit)
        # @units.query.equalTo "property", @model
        @units.comparator = (unit) ->
          title = unit.get "title"
          char = title.charAt title.length - 1
          # Slice off the last digit if it is a letter and add it as a decimal
          if isNaN(char)
            Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
          else
            Number title
      @units.fetch()