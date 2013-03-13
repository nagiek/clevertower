define [
  'underscore',
  'backbone',
], (_, Parse) ->

  Property = Parse.Object.extend "Property",

    defaults:

      image_thumb         : ""
      image_profile       : ""
      image_full          : ""

      description         : ""
      phone               : ""
      email               : ""
      website             : ""
      title               : ""
      property_type       : ""
      year                : ""
      mls                 : ""
      imgs                : []
      tasks               : []
      incomes             : []
      expenses            : []
      vacant_units        : []
      units               : []
      air_conditioning    : 0
      back_yard           : 0
      balcony             : 0
      cats_allowed        : 0
      concierge           : 0
      dogs_allowed        : 0
      doorman             : 0
      elevator            : 0
      exposed_brick       : 0
      fireplace           : 0
      front_yard          : 0
      gym                 : 0
      laundry             : 0
      indoor_parking      : 0
      outdoor_parking     : 0
      pool                : 0
      sauna               : 0
      wheelchair          : 0
      electricity         : 0
      furniture           : 0
      gas                 : 0
      heat                : 0
      hot_water           : 0
      # Private
      init                : 1
      public              : 1

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/property-#{format}.png" unless img?
      img

    # getImgs : ->
    #   # Fallback method
    #   ary = []
    #   if ary.length is 0 
    #     [{thumb: 'img/fallback/property/thumb.png'}]
    #   else 
    #     ary
    # getTasks : ->
    #   []
    # getIncomes : ->
    #   []
    # getExpenses : ->
    #   []
    # getUnits : ->
    #   []