define [
  "jquery"
  "underscore"
  "backbone"
  "collections/PropertyResultsList"
  "views/property/Result"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/property"
  "templates/property/new/map"
  "gmaps"
], ($, _, Parse, PropertyList, PropertyResult, Alert, i18nCommon, i18nProperty) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class GMapView extends Parse.View

    el : ".address-form"
    
    events:
      'keypress #geolocation-search' : 'checkForSubmit'
      'click .search'                : 'geocode'
      'click .geolocate'             : 'geolocate'

    initialize: (attrs) ->
      
      @mapId = "mapCanvas"
      @wizard = attrs.wizard
      
      @geocoder = new google.maps.Geocoder
      @results = new PropertyList

      # Geolocation
      @browserGeoSupport = if navigator.geolocation or google.loader.ClientLocation then true else false

      @listenTo @wizard, "wizard:cancel", @clear
      @listenTo @wizard, "property:save", @clear
      @listenTo @wizard, "lease:save", @clear

      @listenTo @results, "reset", @processResults

    render : ->
      vars = 
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/property/new/map.jst"](vars)
      @$searchInput = @$('#geolocation-search').focus()
      @$propertyList = @$('#search-results')
      # Don't give the option if browser doesn't support it.
      @$('.geolocate').show() unless @browserGeoSupport is false

      @gmap = new google.maps.Map document.getElementById(@mapId), 
        zoom                    : 2
        center                  : new google.maps.LatLng(0,0)
        mapTypeId               : google.maps.MapTypeId.ROADMAP
        mapTypeControl          : false
        streetViewControl       : false
        draggable               : false
        disableDoubleClickZoom  : true
        scrollwheel             : false

      
      if Parse.User.current().get("property")
        new google.maps.Marker 
          position: @model.GPoint()
          map: @map
          ZIndex:   1
          icon: 
            url: "/img/icon/pins-sprite.png"
            size: new google.maps.Size(25, 32, "px", "px")
            origin: new google.maps.Point(50, 0)
            anchor: null
            scaledSize: null

      else if Parse.User.current().get("network")
        for p in Parse.User.current().get("network").properties
          new google.maps.Marker 
            position: @model.GPoint()
            map: @map
            ZIndex: 1
            icon: 
              url: "/img/icon/pins-sprite.png"
              size: new google.maps.Size(25, 32, "px", "px")
              origin: new google.maps.Point(50, @model.pos() * 32)
              anchor: null
              scaledSize: null
      @

    checkForSubmit : (e) =>
      return unless e.keyCode is 13
      @geocode(e)

    geocode : (e) =>      
      e.preventDefault()
      @geocoder.geocode address: @$searchInput.val(), (results, status) =>
        if status is google.maps.GeocoderStatus.OK
          $(".wizard-actions .next").removeProp("disabled") if $(".wizard-actions .next").is("[disabled]")
          if Parse.User.current()
            if Parse.User.current().get("network")
              for p in Parse.User.current().get("network").properties.models
                if results[0].geometry.location.equals p.GPoint()
                  msg = i18nProperty.errors.taken_by_network p.id
                  return new Alert event: 'geocode', fade: false, message: msg, type: 'error'

            # This is preventing us from creating another lease in the same building.
            # 
            # else if Parse.User.current().get("property")
            #   if results[0].geometry.location.equals Parse.User.current().get("property").GPoint()
            #     msg = i18nProperty.errors.taken_by_user Parse.User.current().get("property").id
            #     return new Alert event: 'geocode', fade: false, message: msg, type: 'error'

          @result = @parse results[0]
          @results.setCenter new Parse.GeoPoint(results[0].geometry.location.lat(), results[0].geometry.location.lng())
          @results.fetch()

        else
          alert "Geocoding failed: " + status

    geolocate : (e) =>
      e.preventDefault()
      if @browserGeoSupport
          # First use browser geolocation    
        if navigator.geolocation
          # Set current user location, if available
          navigator.geolocation.getCurrentPosition (position) =>
            @model.set "center", new Parse.GeoPoint(position.coords)
            @geocode latLng: @GPoint @model.get "center"
      
        # If browser geolication is not supoprted, try ip location
        else if google.loader.ClientLocation
          @model.set "center", new Parse.GeoPoint(google.loader.ClientLocation)
          @geocode latLng: @GPoint @model.get "center"
          
      else
        @model.set "center", new Parse.GeoPoint()
        alert i18nProperty.errors.no_geolocaiton
        @geocode latLng: @GPoint @model.get "center"


    # Results Handling
    # ----------------

    processResults: =>
      @model.set @result
      @$searchInput.val @model.get('formatted_address')
      center = @model.GPoint()
      @gmap.setCenter center        
      @setMapZoom()
      if @gmarker then @gmarker.setPosition center else @gmarker = new google.maps.Marker position: center, map: @gmap
      @addAll()

    addOne: (p) =>
      view = new PropertyResult model: p, map: @gmap
      @$propertyList.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: =>
      @$propertyList.html ""
      unless @results.length is 0
        @$('li.empty').remove()
        @results.each @addOne
        @wizard.delegateEvents()
      else
        @$propertyList.html "<li class='empty text-center font-large'>#{i18nProperty.search.no_results}</li>"

    # Utility
    # -------

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

    clear : =>
      @undelegateEvents()
      @remove()
      delete this

    setMapZoom : =>
      switch @model.get "location_type"
        when "APPROXIMATE"
          @gmap.setZoom 10
        when "GEOMETRIC_CENTER"
          @gmap.setZoom 12
        when "RANGE_INTERPOLATED"
          @gmap.setZoom 16
        when "ROOFTOP"
          @gmap.setZoom 16
        else
          @gmap.setZoom 8