define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  'moment'
  "views/activity/List"
  "views/activity/BaseIndex"
  "views/photo/Public"
  "views/listing/PublicSummary"
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
  'templates/activity/modal'
  'templates/comment/summary'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityView, BaseIndexActivityView, PhotoView, ListingView, i18nProperty, i18nListing, i18nUnit, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends BaseIndexActivityView

    el: '#main'

    events:
      'click .nav a'                          : 'showTab'
      'click #activity .thumbnails a.content' : 'getModelDataToShowInModal'
      'click #new-lease'                      : 'showLeaseModal'
      # Activity events
      "click .like-button"                    : "likeOrLogin"
      "click .likers"                         : "showLikers"
      "submit form.new-comment-form"          : "getCommentDataToPost"

    initialize: (attrs) ->

      super

      @place = if attrs.place then attrs.place else @model.city()

      @mapId = "mapCanvas"

      @model.prep "activity"
      @model.prep "comments"
      @model.prep "photos"
      @model.prep "listings"

      @listenTo @model.activity, "add", @addOneActivity
      @listenTo @model.activity, "reset", @addAllActivity

      @listenTo @model.comments, "add", @addOneComment
      @listenTo @model.comments, "reset", @addAllComments

      @listenTo @model.photos, "add", @addOnePhoto
      @listenTo @model.photos, "reset", @addAllPhotos

      @model.listings.title = @model.get "title"
      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

    showTab : (e) ->
      e.preventDefault()
      $("#{e.currentTarget.hash}-link").tab('show')

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

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
      
      @listViews[0] = new infinity.ListView @$('#activity .list-view'), 
        lazy: ->
          pageId = Number $(this).attr(infinity.PAGE_ID_ATTRIBUTE)
          page = infinity.PageRegistry.lookup pageId
          _.each page.items, (item, index) ->
            return if item.loaded
            item.$el.data "pageIndex", index
            data = item.$el.data()
            if data.image then item.$el.find(".content .photo img").prop 'src', data.image
            if data.profile then item.$el.find("footer img.profile-pic").prop 'src', data.profile
            item.loaded = true


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
          animation: google.maps.Animation.DROP
          icon: 
            url: "/img/icon/pins-sprite.png"
            size: new google.maps.Size(25, 32, "px", "px")
            origin: new google.maps.Point(0, 0)
            anchor: null
            scaledSize: null

      @$loading = @$("#activity .loading")

      # @$activity = @$("#activity ul")
      @$photos = @$("#photos ul")
      @$listings = @$("#listings > table > tbody")
      
      # Start activity search.
      if @model.activity.length > @resultsPerPage * (@page - 1) and @model.comments.length > @commentsPerPage * (@page - 1)
        @addAllActivity()
        @addAllComments @model.comments
      else @search()
      @updatePaginiation()

      if @model.photos.length > 0 then @addAllPhotos() else @model.photos.fetch()
      if @model.listings.length > 0 then @addAllListings() else @model.listings.fetch()

      # Track scrolling for infinity
      $(window).scroll @loadTracker
      $(document.documentElement).scroll @loadTracker

      @


    # BaseIndex Linkers
    # ------------------

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parent().data()

      # Keep track of where we are, for subsequent navigation.
      # Convert the index to an array and find the "new" index.
       
      # This is using the cached results done in addAllActivity
      # @modalCollection = @model.activity.select (a) => a.get("property") and a.get("property").id is @model.id
      model = @model.activity.at data.index

      ids = _.map(@modalCollection, (a) -> a.id)
      @modalIndex = _.indexOf(ids, model.id)

      console.log model.id
      console.log ids
      console.log data.index
      console.log @modalIndex
      console.log @modalCollection

      @showModal()

    getCommentDataToPost: (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.activity.at(data.index)

      @postComment activity, data, model


    # Activity
    # ------
    search : =>

      @$loading.html "<img src='/img/misc/spinner.gif' class='spinner' alt='#{i18nCommon.verbs.loading}' />"
      @moreToDisplay = true

      # handleMapActivity
      Parse.Promise.when(
        @model.activity.query.skip(@resultsPerPage * (@page - 1)).limit(@resultsPerPage).find(),
        @model.comments.query.skip(@commentsPerPage * (@page - 1)).limit(@commentsPerPage).find()
      ).then (objs, comms) =>
        if objs
          # Set the property, as we have not included it.
          _.each objs, (o) => o.set "property", @model
          @model.activity.add objs
        if comms 
          _.each comms, (c) => c.set "property", @model
          @model.comments.add comms
        @addAllComments comms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount

    checkIfEnd : =>

      # Check if we have hit the end.
      if @model.activity.length >= @activityCount then @trigger "view:exhausted"

    # addOneActivity : (activity) =>
    #   view = new ActivityView(model: activity, onProfile: false)
    #   @$activity.append view.render().el

    updatePaginiation : =>
      countQuery = @model.activity.query
      # Reset old filters
      countQuery.notContainedIn("objectId", [])
      # Limit of -1 means do not send a limit.
      countQuery.limit(-1).skip(0)

      countQuery.count()
      .then (count) =>

        @activityCount = count
        @pages = Math.ceil((count)/ @resultsPerPage)
        # @$pagination.html ""
        if count is 0 then @trigger "view:empty"

        @checkIfEnd()
          
        #   @renderPaginiation()

    addAllActivity: (collection, filter) =>

      visible = @modalCollection = @model.activity.select (a) => a.get("property") and a.get("property").id is @model.id
      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + i18nProperty.tenant_empty.activity + '</div>'

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
        @$photos.html '<li class="empty offset2 span4">' + i18nProperty.tenant_empty.photos + '</li>'

    # Listings
    # --------

    addOneListing : (listing) =>
      @$listings.append new ListingView(model: listing).render().el
      
    addAllListings: (collection, filter) =>

      @$listings.html ""

      visible = @model.listings.select (a) => a.get("property").id is @model.id
      $('#listings-link .count').html visible.length

      if visible.length > 0 

        # Get listings with unknown # of bedrooms.
        listings = _.filter visible, (l) -> l.get("bedrooms") is undefined
        if listings.length > 0
          @$listings.append "<tr class='divider'><td colspan='4'>#{i18nUnit.fields.bedrooms}: #{i18nCommon.adjectives.not_specified}</td></tr>"
          _.each listings, @addOneListing

        # Get listings where we have a # of bedooms.
        for i in [0..6]
          listings = _.filter visible, (l) -> l.get("bedrooms") is i
          if listings.length > 0
            @$listings.append '<tr class="divider"><td colspan="4">' + i18nUnit.fields.bedrooms + ": #{i}</td></tr>"
            _.each listings, @addOneListing
      else
        @$listings.html "<tr class='empty'><td colspan='4'>#{i18nProperty.tenant_empty.listings}</td></tr>"

    # Lease Modal
    # -----------

    showLeaseModal: (e) =>
      e.preventDefault()
      if Parse.User.current()
        require ['models/Lease', 'views/lease/New'], (Lease, NewLeaseView) =>
          @lease = new Lease property: @model, forNetwork: false unless @lease
          new NewLeaseView(model: @lease, property: @model, network: @model.get("network"), modal: true).render().$el.modal()
      else
        $("#signup-modal").modal()
