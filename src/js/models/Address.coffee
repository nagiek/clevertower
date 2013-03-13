define [
  'underscore',
  'backbone',
  "gmaps"
], (_, Parse) ->

  Address = Parse.Object.extend "Address",

    # explicitly specifiy the model
    defaults:
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

    # convenience function
    toGPoint: ->
      new google.maps.LatLng @get("center")._latitude, @get("center")._longitude