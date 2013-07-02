define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/List"
  "views/photo/Public"
  "views/listing/PublicSummary"
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
  "gmaps"
], ($, _, Parse, ActivityView, PhotoView, ListingView, i18nProperty, i18nListing, i18nUnit, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends Parse.View

    el: '#main'

    events:
      'click .nav a' : 'showTab'
      'click #new-lease' : 'showModal'

    initialize: (attrs) ->

      @place = if attrs.place then attrs.place else @model.get("locality") + "--" + @model.get("administrative_area_level_1") + "--" + Parse.App.countryCodes[@model.get("country")]

      @mapId = "mapCanvas"

      @model.prep "activity"
      @model.prep "photos"
      @model.prep "listings"

      @listenTo @model.activity, "add", @addOneActivity
      @listenTo @model.activity, "reset", @addAllActivity

      @listenTo @model.photos, "add", @addOnePhoto
      @listenTo @model.photos, "reset", @addAllPhotos

      @model.listings.title = @model.get "title"
      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

    showTab : (e) ->
      e.preventDefault()
      $("#{e.currentTarget.hash}-link").tab('show')

    render: ->
      vars =
        property: @model.toJSON()
        place: @place
        cover: @model.cover('span9')
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
        i18nListing: i18nListing
        i18nUnit: i18nUnit

      @$el.html JST["src/js/templates/property/public.jst"](vars)

      center = @model.GPoint()

      map = new google.maps.Map document.getElementById(@mapId), 
        zoom          : 15
        center        : center
        mapTypeId     : google.maps.MapTypeId.ROADMAP

      if @model.get "approx"
        marker = new google.maps.Circle
          center:         center
          map:            map
          radius:         250
          fillColor:      "#f8aa6f"
          fillOpacity:    0.5
          strokeColor:    "#f28255"
          strokeOpacity:  0.8
          strokeWeight:   3
      else
        marker = new google.maps.Marker
          position: center
          map:      map

      @$activity = $("#activity > ul")
      @$photos = $("#photos > ul")
      @$listings = $("#listings > table > tbody")
      
      if @model.activity.length is 0 then @model.activity.fetch() else @addAllActivity()
      if @model.photos.length is 0 then @model.photos.fetch() else @addAllPhotos()
      if @model.listings.length is 0 then @model.listings.fetch() else @addAllListings()

      @

    # Activity
    # ------

    addOneActivity : (activity) =>
      view = new ActivityView(model: activity)
      @$activity.append view.render().el
      
    addAllActivity: (collection, filter) =>

      @$activity.html ""
      unless @model.activity.length is 0
        @model.activity.each @addOneActivity
      else
        @$activity.before '<p class="empty">' + i18nProperty.tenant_empty.activity + '</p>'

    # Photos
    # ------

    addOnePhoto : (photo) =>
      view = new PhotoView(model: photo)
      @$photos.append view.render().el
      
    addAllPhotos: (collection, filter) =>

      $('#photos-link .count').html @model.photos.length

      @$photos.html ""
      unless @model.photos.length is 0
        @model.photos.each @addOnePhoto
      else
        @$photos.before '<p class="empty">' + i18nProperty.tenant_empty.photos + '</p>'

    # Listings
    # --------

    addOneListing : (listing) =>
      @$listings.append new ListingView(model: listing).render().el
      
    addAllListings: (collection, filter) =>

      $('#listings-link .count').html @model.listings.length

      @$listings.html ""
      unless @model.listings.length is 0

        # Get listings with unknown # of bedrooms.
        listings = @model.listings.filter (l) -> l.get("bedrooms") is undefined
        if listings.length > 0
          @$listings.append "<tr class='divider'><td colspan='4'>#{i18nUnit.fields.bedrooms}: #{i18nCommon.adjectives.not_specified}</td></tr>"
          _.each listings, @addOneListing

        # Get listings where we have a # of bedooms.
        for i in [0..6]
          listings = @model.listings.filter (l) -> l.get("bedrooms") is i
          if listings.length > 0
            @$listings.append '<tr class="divider"><td colspan="4">' + i18nUnit.fields.bedrooms + ": #{i}</td></tr>"
            _.each listings, @addOneListing
      else
        @$listings.before "<tr class='empty'><td colspan='4'>#{i18nProperty.tenant_empty.listings}</td></tr>"

    showModal: (e) =>
      e.preventDefault()
      if Parse.User.current()
        require ['models/Lease', 'views/lease/New'], (Lease, NewLeaseView) =>
          @lease = new Lease property: @model, forNetwork: false unless @lease
          new NewLeaseView(model: @lease, property: @model, network: @model.get("network"), modal: true).render().$el.modal()
      else
        $("#signup-modal").modal()