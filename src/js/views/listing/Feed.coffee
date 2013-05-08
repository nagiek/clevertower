define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/listing/feedList'
  'templates/listing/feedPhoto'
], ($, _, Parse, moment, i18nListing, i18nCommon) ->

  class ListingFeedView extends Parse.View
  
    tagName: "li"
    className: "span4"

    events:
      "mouseover > a" : "highlightMarker"
      "mouseout > a"  : "unHighlightMarker"
      "click a" : "goToProperty"

    initialize : (attrs) ->
      @view = attrs.view
      @display = @view.display
      @map = @view.map

      @listenTo @model, "remove", @clear
      @listenTo @view, "view:changeDisplay", @setDisplay
      @listenTo @view, "model:viewDetails", @clear

      @icon = 
        url: "/img/icon/pins-sprite.png"
        size: new google.maps.Size(25, 32, "px", "px")
        origin: new google.maps.Point(0, @model.pos() * 32)
        anchor: null
        scaledSize: null

    # attributes: =>
    #   console.log @display

    # This fn needed to correctly set this attribute from within an event.
    setDisplay: (display) => @display = display; @render()

    undelegateEvents: =>
      google.maps.event.removeListener @highlightListener
      google.maps.event.removeListener @unHighlightListener
      super

    goToProperty: (e) =>
      e.preventDefault()
      require ["views/property/Public"], (PublicPropertyView) => 
        property = @model.get("property")
        new PublicPropertyView(model: property).render()
        Parse.history.navigate "/public/#{property.id}"
        @view.trigger "model:viewDetails"


    # Re-render the contents of the Unit item.
    render: =>
      vars = 
        title: @model.get("title")
        rent: "$" + @model.get("rent")
        pos: @model.pos() + 1
        propertyId: @model.get("property").id
        cover: @model.get("property").cover('large')
        createdAt: moment(@model.createdAt).fromNow()
        i18nCommon: i18nCommon
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/listing/feed#{@display}.jst"](vars)
      
      unless @marker
        @marker = new google.maps.Marker
          position: @model.GPoint()
          map: @map
          icon: @icon

        @highlightListener = google.maps.event.addListener @marker, "mouseover", @highlightMarker
        @unHighlightListener = google.maps.event.addListener @marker, "mouseout", @unHighlightMarker

      @

    highlightMarker : =>
      @$('> a').addClass('active')
      @icon.origin = new google.maps.Point(25, @model.pos() * 32)
      @marker.setIcon @icon
      @marker.setZIndex 10
      

    unHighlightMarker : =>
      @$('> a').removeClass('active')
      @icon.origin = new google.maps.Point(0, @model.pos() * 32)
      @marker.setIcon @icon
      @marker.setZIndex 1

    clear : => 
      @marker.setMap null
      @model.off "remove", @el
      @view.off "view:changeDisplay", @el
      delete @model
      delete @marker
      @remove()
      @undelegateEvents()
      delete this