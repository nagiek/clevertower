define [
  "jquery"
  "underscore"
  "backbone"
  "models/address"
  "gmaps"
  'templates/address/map'
], ($, _, Parse, Address) ->

  class GPointView extends Parse.View

    initialize: (attrs) ->

      # Grab attrs not automatically defined
      @gmap = attrs.gmap
      @$searchInput = attrs.$searchInput

      @el = "#" + @model.divId

      @gMarker = new google.maps.Marker(
        position: @model.toGPoint()
        map: @gmap
      )

      # update the position when the point changes
      @model.on "change", (updatedPoint) =>
        @gMarker.setPosition updatedPoint.toGPoint()
        @render()
        
      # update the position when the point changes
      @model.on "remove",  =>
        @remove()
        delete this

      @render()

    setMapZoom : (location_type) ->
      switch location_type
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

    render: ->
      @setMapZoom               @model.get('location_type')
      @$searchInput.val         @model.get('formatted_address')
      @model.$location_type.val @model.get('location_type')
      # @model.$adrsLat.val       @model.get('lat')
      # @model.$adrsLat.val       @model.get('lng')
      @model.$adrsThr.val       @model.get('thoroughfare')
      @model.$adrsLty.val       @model.get('locality')
      @model.$adrsNhd.val       @model.get('neighbourhood')
      @model.$adrsAd1.val       @model.get('administrative_area_level_1')
      @model.$adrsAd2.val       @model.get('administrative_area_level_2')
      @model.$adrsCty.val       @model.get('country')
      @model.$adrsPCd.val       @model.get('postal_code')
      this

    remove: ->
      @gMarker.setMap               null
      @gMarker =                    null
      @model.$formatted_address.val ''
      @model.$location_type.val     ''
      @model.$adrsLat.val           ''
      @model.$adrsLng.val           ''
      @model.$adrsThr.val           ''
      @model.$adrsLty.val           ''
      @model.$adrsAdm.val           ''
      @model.$adrsCty.val           ''
      @model.$adrsPCd.val           ''
      super
