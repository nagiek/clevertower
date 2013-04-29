define [
  "jquery"
  "underscore"
  "backbone"
  "views/photo/Public"
  "views/listing/Headline"
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
  "gmaps"
], ($, _, Parse, PhotoView, ListingView, i18nProperty, i18nListing, i18nUnit, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends Parse.View

    el: '#main'

    events:
      'click .nav a' : 'showTab'
      'click #new-lease' : 'showModal'

    initialize: ->

      _.bindAll @, 'showTab', 'render', 'addOne', 'addAll', 'addOneListing', 'addAllListings', 'showModal'

      @mapId = "mapCanvas"

      @model.prep "photos"
      @model.prep "listings"

      @model.photos.bind "add", @addOne
      @model.photos.bind "reset", @addAll

      @model.listings.title = @model.get "title"
      @model.listings.bind "add", @addOneListing
      @model.listings.bind "reset", @addAllListings

    GPoint : (GeoPoint)-> new google.maps.LatLng GeoPoint._latitude, GeoPoint._longitude

    showTab : (e) ->
      e.preventDefault()
      $(e.currentTarget).tab('show')

    render: ->
      vars =
        property: @model.toJSON()
        cover: @model.cover('span9')
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
        i18nListing: i18nListing
        i18nUnit: i18nUnit

      @$el.html JST["src/js/templates/property/public.jst"](vars)

      center = @GPoint @model.get("center")

      map = new google.maps.Map document.getElementById(@mapId), 
        zoom          : 16
        center        : center
        mapTypeId     : google.maps.MapTypeId.ROADMAP

      marker = new google.maps.Marker
        position: center
        map:      map

      @$list = $("#photos > ul")
      @$listings = $("#listings > table > tbody")
      
      if @model.photos.length is 0 then @model.photos.fetch() else @addAll
      if @model.listings.length is 0 then @model.listings.fetch() else @addAllListings

      @

    # Photos
    # ------

    addOne : (photo) =>
      view = new PhotoView(model: photo)
      @$list.append view.render().el
      
    addAll: (collection, filter) =>

      $('#photos-link .count').html @model.listings.length

      @$list.html ""
      unless @model.photos.length is 0
        @model.photos.each @addOne
      else
        @$list.before '<p class="empty">' + i18nProperty.collection.empty.photos + '</p>'

    # Listings
    # --------

    addOneListing : (listing) =>
      view = new ListingView(model: listing)
      @$listings.append view.render().el
      
    addAllListings: (collection, filter) =>

      $('#listings-link .count').html @model.listings.length

      @$listings.html ""
      unless @model.listings.length is 0
        for i in [0..6]
          listings = @model.listings.filter (l) -> l.get("unit").get("bedrooms") is i
          if listings.length > 0
            @$listings.append '<tr class="divider"><td colspan="4">' + i18nUnit.fields.bedrooms + ": #{i}</td></tr>"
            _.each listings, @addOneListing
      else
        @$listings.before '<p class="empty">' + i18nProperty.collection.empty.photos + '</p>'

    showModal: (e) =>
      e.preventDefault()
      require ['models/Lease', 'views/lease/New'], (Lease, LeaseView) =>
        @lease = new Lease property: @model unless @lease
        new LeaseView(model: @lease, property: @model, modal: true).render().$el.modal()
