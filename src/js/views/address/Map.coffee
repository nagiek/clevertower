define [
  "jquery"
  "underscore"
  "backbone"
  'models/Map'
  "views/address/Point"
  "i18n!nls/address"
  "templates/address/map"
  "gmaps"
], ($, _, Parse, Map, GPointView, i18nAddress) ->

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
      
      divId = "mapCanvas"
      
      @address = attrs.address
      @wizard = attrs.wizard
      
      @model = new Map divId: divId, marker: @address
      
      @$searchInput = @$el.find('#geolocation-search').focus()

      # Geolocation
      @browserGeoSupport = if navigator.geolocation or google.loader.ClientLocation then true else false

      # Don't give the option if browser doesn't support it.
      @$el.find('.geolocate').show() unless @browserGeoSupport == false

      @gmap = new google.maps.Map document.getElementById(divId), @model.get "opts"

      # object.listenTo(other, event, callback)   # Should be using this form
      @wizard.on "wizard:cancel", =>
        @undelegateEvents()
        @remove()
        delete @gmap
        delete @marker
        delete @model
        delete this
      
      # object.listenTo(other, event, callback) 
      @wizard.on "property:save", =>
        @undelegateEvents()
        @remove()
        delete @gmap
        delete @marker
        delete @model
        delete this

      # update the center when the point changes
      @model.marker.on "change", (updatedPoint) =>
        @gmap.setCenter updatedPoint.toGPoint()

      # convert added point to new marker
      @model.on "marker:add", (newPoint) =>

        @marker = new GPointView(
          model: newPoint
          gmap: @gmap
          $searchInput: @$searchInput
        )

      @model.on "marker:remove", (removedPoint) ->

        # map the model remove to a Marker remove
        @model.marker.remove()
        delete @marker

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
        alert i18nAddress.errors.messages.no_geolocation

    render: ->
      this
