define [
  "jquery"
  "underscore"
  "backbone"
  'models/Map'
  "i18n!nls/common"
  "i18n!nls/property"
  "templates/property/new/map"
  "gmaps"
], ($, _, Parse, Map, i18nCommon, i18nProperty) ->

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
      
      _.bindAll this, 'checkForSubmit', 'geocode', 'geolocate'
      
      @mapId = "mapCanvas"
      
      @wizard = attrs.wizard
      @marker = attrs.marker
      
      @model = new Map divId: @mapId, marker: @marker

      # Geolocation
      @browserGeoSupport = if navigator.geolocation or google.loader.ClientLocation then true else false

      # object.listenTo(other, event, callback)   # Parse doesn't yet support this function
      @wizard.on "wizard:cancel", =>
        @undelegateEvents()
        @remove()
        delete this
      
      @wizard.on "property:save", =>
        @undelegateEvents()
        @remove()
        delete this

      # update the center when the point changes
      @marker.on "change", (updatedPoint) =>
        @$searchInput.val updatedPoint.get('formatted_address')
        center = @model.GPoint updatedPoint.get "center"
        @gmap.setCenter center        
        @setMapZoom updatedPoint
        if @gmarker then @gmarker.setPosition center else @gmarker = new google.maps.Marker position: center, map: @gmap

      @model.on "marker:remove", (removedPoint) ->
        # map the model remove to a Marker remove
        @gmarker.setMap null
        delete @marker

    render : ->
      @$el.html JST["src/js/templates/property/new/map.jst"](i18nProperty: i18nProperty, i18nCommon: i18nCommon)
      @$searchInput = @$('#geolocation-search').focus()
      # Don't give the option if browser doesn't support it.
      @$('.geolocate').show() unless @browserGeoSupport is false
      @gmap = new google.maps.Map document.getElementById(@mapId), @model.get "opts"
      @

    checkForSubmit : (e) ->
      return unless e.keyCode is 13
      @geocode(e)

    geocode : (e) ->
      e.preventDefault()
      @model.geocode address: @$searchInput.val()

    geolocate : (e) ->
      e.preventDefault()
      if @browserGeoSupport
        @model.geolocate()
      else
        alert i18nProperty.errors.messages.no_geolocation

    setMapZoom : (marker) =>
      switch marker.get "location_type"
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