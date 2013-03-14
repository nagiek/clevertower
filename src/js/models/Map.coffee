define [
  "jquery"
  "underscore"
  "backbone"
  "gmaps"
], ($, _, Parse) ->

  Map = Parse.Object.extend "Map",
  
    # by default models can't be nested
    initialize : (attrs) ->
      
      # Backbone.Model::initialize.apply this, arguments
      # @set divId: divId
      
      @geocoder = new google.maps.Geocoder()
      
      @marker = attrs.marker
      
      opts = 
        zoom          : 2
        center        : @GPoint(@marker.get "center")
        mapTypeId     : google.maps.MapTypeId.ROADMAP
      
      # @opts = _.defaults(attrs.mapOpts, mapDefaults)
      
      @set 
        "point_exists": false
        "opts": opts
        
        
    GPoint : (GeoPoint)->
      new google.maps.LatLng GeoPoint._latitude, GeoPoint._longitude
           
    geocode : (inputHash) ->
      
      @geocoder.geocode inputHash, (results, status) =>
        if status is google.maps.GeocoderStatus.OK
          @marker.set @parse(results[0])
          unless @get "point_exists"
            @set "point_exists", true
            @trigger "marker:add", @marker
        else
          alert "Geocoding failed: " + status

    parse : (res) ->
      components = 
        'formatted_address'   : res.formatted_address
        'center'              : new Parse.GeoPoint res.geometry.location.lat(), res.geometry.location.lng()
        'location_type'       : res.geometry.location_type
    
      street_number = '';
      route = '';
    
      _.each res.address_components, (c) ->
        switch c.types[0]
          when 'street_number'
            street_number = c.long_name
            break
          when 'route'
            route = c.long_name
            break
          when 'locality'
            components.locality = c.long_name
            break
          when 'neighborhood'
            # Replace the city if we don't have one.
            # components.locality ||= c.long_name
            neighborhood = c.long_name
            break
          when 'administrative_area_level_1'
            components.administrative_area_level_1 = c.short_name.substr(0,2).toUpperCase()
            break
          when 'administrative_area_level_2'
            components.administrative_area_level_2 = c.short_name.substr(0,2).toUpperCase()
            break
          when 'country'
            components.country = c.short_name.substr(0,2).toUpperCase()
            break
          when 'postal_code'
            components.postal_code = c.long_name
            break
      components.thoroughfare = street_number + " " + route
      return components
       
    geolocate : (e) ->

      # First use browser geolocation    
      if navigator.geolocation
        # Set current user location, if available
        navigator.geolocation.getCurrentPosition (position) =>
          @marker.set "center", new Parse.GeoPoint(position.coords)
          @geocode latLng: @GPoint @marker.get "center"
    
      # If browser geolication is not supoprted, try ip location
      else if google.loader.ClientLocation
        @marker.set "center", new Parse.GeoPoint(google.loader.ClientLocation)
        @geocode latLng: @GPoint @marker.get "center"
        
      else
        @marker.set "center", new Parse.GeoPoint()
        alert i18nProperty.errors.no_geolocaiton
        @geocode latLng: @GPoint @marker.get "center"