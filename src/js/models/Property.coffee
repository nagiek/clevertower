define [
  'underscore'
  'backbone'
  "collections/UnitList"
  "collections/LeaseList"
  "collections/InquiryList"
  "collections/TenantList"
  "collections/ApplicantList"
  "collections/ListingList"
  "collections/PhotoList"
  "collections/ActivityList"
  "collections/CommentList"
  "models/Unit"
  "models/Lease"
  "i18n!nls/common"
], (_, Parse, UnitList, LeaseList, InquiryList, TenantList, ApplicantList, ListingList, PhotoList, ActivityList, CommentList, Unit, Lease, i18nCommon) ->

  Property = Parse.Object.extend "Property",
  # class Property extends Parse.Object
    
    className: "Property"
          
    defaults:
      # Location
      center                        : new Parse.GeoPoint
      offset                        : 
        lat                         : 50
        lng                         : 50
      formatted_address             : ''
      address_components            : []
      location_type                 : "APPROXIMATE"
      thoroughfare                  : ''
      locality                      : ''
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
    GPoint : -> 
      # @get("offset") will be from 0-99
      # degrees N/S or E/W at equator  E/W at 23N/S E/W at 45N/S E/W at 67N/S
      # 0.0001  11.132 m  10.247 m  7.871 m

      center = @get "center"
      return new google.maps.LatLng 0,0 unless center
      offset = @get "offset" || lat: 50, lng: 50

      lat = center._latitude + (offset.lat - 50) * 250 * 7.871 / 100000000
      lng = center._longitude + (offset.lng - 50) * 250 * 7.871 / 100000000

      new google.maps.LatLng lat, lng

    # Backbone default, as Parse function does not exist.
    url: -> "/properties/#{@id}"
    
    # URL friendly title
    publicUrl: -> "/places/#{@country()}/#{@get("administrative_area_level_1")}/#{@get("locality")}/#{@id}/#{@slug()}"
    slug: -> @get("profile").name().replace(/\s+/g, '-').toLowerCase()
    country: -> i18nCommon.countries[@get("country")]

    city: -> 
      if @get("location") then @get("location").url()
      else  
        @get("locality").replace(/\s+/g, '-') + "--"
        + @get("administrative_area_level_1").replace(/\s+/g, '-') + "--"
        + i18nCommon.countries[@get("country")].replace(/\s+/g, '-')

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
        'approx'
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
      basedOnNetwork = user and network and @get("network") and @get("network").id is network.id

      @[collectionName] = switch collectionName
        when "leases"
          new LeaseList [], property: @
        when "photos"
          new PhotoList [], property: @
        when "activity"
          if basedOnNetwork then network.activity else new ActivityList [], property: @
        when "comments"
          if basedOnNetwork then network.comments else new CommentList [], property: @
        when "units" 
          if basedOnNetwork then network.units else new UnitList [], property: @
        when "inquiries"
          if basedOnNetwork then network.inquiries else new InquiryList [], property: @
        when "listings"
          if basedOnNetwork then network.listings else new ListingList [], property: @
        when "tenants"
          if basedOnNetwork then network.tenants else new TenantList [], property: @
        when "applicants"
          if basedOnNetwork then network.applicants else new ApplicantList [], property: @

      @[collectionName]



  # CLASS METHODS
  # -------------

  Property.url = (id) -> "/properties/#{id}"
  Property.publicUrl = (country, area, locality, id, slug) -> "/places/#{country}/#{area}/#{locality}/#{id}/#{slug}"
  Property.slug = (title) -> title.replace(/\s+/g, '-').toLowerCase()
  Property.country = (country) -> i18nCommon.countries[country]


  Property