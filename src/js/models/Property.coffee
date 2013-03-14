define [
  'underscore',
  'backbone',
], (_, Parse) ->

  Property = Parse.Object.extend "Property",

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

    initialize : (attrs) ->  
      # @$adrsLat =           $('#address_lat',                         '.address-form')
      # @$adrsLng =           $('#address_lng',                         '.address-form')
      # @$resultComponents =  $('#address_components',                  '.address-form')
      # @$location_type =     $('#address_location_type',               '.address-form')
      # @$adrsThr =           $('#address_thoroughfare',                '.address-form')
      # @$adrsLty =           $('#address_locality',                    '.address-form')
      # @$adrsNhd =           $('#address_neighbourhood',               '.address-form')
      # @$adrsAd1 =           $('#address_administrative_area_level_1', '.address-form')
      # @$adrsAd2 =           $('#address_administrative_area_level_2', '.address-form')
      # @$adrsCty =           $('#address_country',                     '.address-form')
      # @$adrsPCd =           $('#address_postal_code',                 '.address-form')

      # route changes to model listeners
      @trigger "marker:add", this

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/property-#{format}.png" if img is ''
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