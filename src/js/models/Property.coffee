define [
  'underscore',
  'backbone',
  "collections/UnitList"
  "collections/LeaseList"
  "collections/InquiryList"
  "collections/TenantList"
  "collections/ApplicantList"
  "collections/ListingList"
  "collections/PhotoList"
  "models/Unit"
  "models/Lease"
  "underscore.inflection"
], (_, Parse, UnitList, LeaseList, InquiryList, TenantList, ApplicantList, ListingList, PhotoList, Unit, Lease, Listing, inflection) ->

  Property = Parse.Object.extend "Property",
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


    # Index of model in its collection.
    pos : -> if @collection then @collection.indexOf(@) else 0

    # Helper function
    GPoint : -> new google.maps.LatLng @get("center")._latitude, @get("center")._longitude

    # Backbone default, as Parse function does not exist.
    url: -> "/#{@collection.url}/#{@id}"
    
    # URL friendly title
    publicUrl: -> "/places/#{@country()}/#{@get("administrative_area_level_1")}/#{@get("locality")}/#{@id}/#{@slug()}"

    slug: -> @get("title").replace(/\s+/g, '-').toLowerCase()

    country: -> Parse.App.countryCodes[@get("country")]

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/property-#{format}.png" if img is '' or !img?
      img 

    scrub: (attrs) ->
      bools = ['electricity'
        'furniture'
        'gas'
        'heat'
        'hot_water'
        # Included
        'air_conditioning'
        'back_yard'
        'balcony'
        'cats_allowed'
        'concierge'
        'dogs_allowed'
        'doorman'
        'elevator'
        'exposed_brick'
        'fireplace'
        'front_yard'
        'gym'
        'laundry'
        'indoor_parking'
        'outdoor_parking'
        'pool'
        'sauna'
        'wheelchair'
        # Private
        'public'
        'anon'
      ]

      for attr in bools
        attrs[attr] = if attrs[attr] is "on" or attrs[attr] is "1" then true else false
      
      attrs

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]

      user = Parse.User.current()
      network = user.get("network") if user
      basedOnNetwork = user and network and @get("network").id is network.id

      @[collectionName] = switch collectionName
        when "units" 
          new UnitList [], property: @
        when "leases"
          new LeaseList [], property: @
        when "photos"
          new PhotoList [], property: @
        when "inquiries"
          if basedOnNetwork then network.inquiries else new InquiryList [], property: @
        when "listings"
          if basedOnNetwork then network.listings else new ListingList [], property: @
        when "tenants"
          if basedOnNetwork then network.tenants else new TenantList [], property: @
        when "applicants"
          if basedOnNetwork then network.applicants else new ApplicantList [], property: @

      @[collectionName]

