define [
  'underscore',
  'backbone',
  "collections/unit/UnitList"
  "collections/lease/LeaseList"
  "models/Unit"
  "models/Lease"
  "underscore.inflection"
], (_, Parse, UnitList, LeaseList, Unit, Lease, inflection) ->

  Property = Parse.Object.extend "Property"
  # class Property extends Parse.Object
    
    className: "Property"
      
    initialize: ->
      _.bindAll @, "cover", "prep"
          
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
      
      # Managers
      # These break the data browser
      # managers_pending: new Parse.Relation
      # managers_invited: new Parse.Relation
      # managers_current: new Parse.Relation
      
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

    # Backbone default, as Parse function does not exist.
    url: -> "/#{@collection.url}/#{@id}"

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/property-#{format}.png" if img is '' or !img?
      img 

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      switch collectionName
        when "units" 
          @[collectionName] = new UnitList [], property: @
        when "leases"
          @[collectionName] = new LeaseList [], property: @
        when "tenants"
          user = Parse.User.current()
          network = user.get("network") if user
          unless user and network
            @[collectionName] = new TenantList [], lease: @
          else
            @[collectionName] = if network.tenants then network.tenants else new TenantList [], lease: @

      @[collectionName]

