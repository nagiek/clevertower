define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  'moment'
  "collections/ActivityList"
  "collections/CommentList"
  "views/helper/Alert"
  "views/activity/BaseIndex"
  "views/photo/Public"
  "views/listing/PublicSummary"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/listing"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
  'templates/activity/modal'
  'templates/comment/summary'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Alert, BaseIndexActivityView, PhotoView, ListingView, i18nProperty, i18nUnit, i18nListing, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends BaseIndexActivityView

    el: '#main'

    events:
      'click .nav a'                            : 'showTab'
      'click #activity .thumbnails a.content'   : 'getModelDataToShowInModal'
      'click .thumbnails button.get-comments'   : 'getActivityCommentsAndCollection' # 'showModal'
      'click #new-lease'                        : 'showLeaseModal'
      # Activity events
      "click .like-button"                      : "likeOrLoginFromActivity"
      "click .likers"                           : "getLikersFromActivity"
      "submit form.new-comment-form"            : "getCommentDataToPost"

    initialize: (attrs) ->

      super

      @place = if attrs.place then attrs.place else @model.city()

      @mapId = "mapCanvas"

      @model.prep "activity"
      @model.prep "comments"
      @model.prep "photos"
      @model.prep "listings"

      # Do not add activity, as we may get extra items added.
      # @listenTo @model.activity, "add", @addOneActivity
      # @listenTo @model.activity, "reset", @addAllActivity

      # @listenTo @model.comments, "add", @addOneComment
      # @listenTo @model.comments, "reset", @addAllComments

      @listenTo @model.photos, "add", @addOnePhoto
      @listenTo @model.photos, "reset", @addAllPhotos

      @model.listings.title = @model.get "title"
      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

      if Parse.App.activity and Parse.App.comments
        activity = Parse.App.activity.select((a) => a.get("property") and a.get("property").id is @model.id)
        # Move models from the general collection to the property
        Parse.App.activity.remove activity
        @model.activity.add activity
        @model.activity.query.notContainedIn "objectId", _.map(activity, (a) -> a.id)

        comments = Parse.App.comments.select((c) => c.get("property") and c.get("property").id is @model.id)
        Parse.App.comments.remove comments
        @model.comments.add comments
        @model.comments.query.notContainedIn "objectId", _.map(comments, (c) -> c.id)

    showTab : (e) ->
      e.preventDefault()
      $("#{e.currentTarget.hash}-link").tab('show')

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    checkIfFollowing: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsFollowing(activity) if Parse.User.current().get("profile").following.find (p) => p.id is model.get("profile").id

    render: ->

      vars =
        property: @model.toJSON()
        profile: @model.get("profile").toJSON()
        place: @place
        cover: @model.get("profile").cover('full')
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
      @addAllActivity @model.activity if @model.activity.length > 0
      @addAllComments @model.comments if @model.comments.length > 0
      @search() unless @model.activity.length > @resultsPerPage * @page

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
       
      # Could use the cached results from addAllActivity unless we've loaded new data
      @modalCollection = @findModelActivity @model.activity
      @modalCommentCollection = @findModelComments @model.comments
      
      model = @model.activity.at data.index

      ids = _.map(@modalCollection, (a) -> a.id)
      @modalIndex = _.indexOf(ids, model.id)

      @showModal()

    getCommentDataToPost: (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.activity.at(data.index)

      @postComment activity, model

    getActivityCommentsAndCollection : (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.activity.at(data.index)
      comments = @model.comments

      button.button("loading")

      @getActivityComments(model, comments).then (newComms) =>
        addedComms = comments.add newComms
        @addAllComments addedComms
        button.button("reset")
      , =>
        button.button("reset")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'danger'

    addCommentToCollection : (comment) => @model.comments.add comment 

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

          # Set the property, as we may have not included it for property-specific queries.
          if objs[0] and not objs[0].get "property"
            _.each objs, (o) => o.set "property", @model

          addedObjs = @model.activity.add objs

          # We may be getting non-related models at this point.
          @addAllActivity addedObjs
          
          if objs.length < @resultsPerPage then @trigger "view:exhausted"
        else 
          @trigger if @model.activity.length > 0 then "view:exhausted" else "view:empty"

        if comms 
          _.each comms, (c) => c.set "property", @model
          addedComms = @model.comments.add comms

          @addAllComments addedComms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount

      # Save the hassle of updatePaginiation on the first go-round.
      # We can infer whether we need it the second time around.
      if @page is 2 then @updatePaginiation()

    checkIfEnd : =>

      # Check if we have hit the end.
      if @model.activity.length >= @activityCount then @trigger "view:exhausted"

    likeOrLoginFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.activity.at(data.index)

      if Parse.User.current()
        @like model, activity, button, data, false
      else
        $("#signup-modal").modal()

    getLikersFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.activity.at(data.index)

      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikers
      model.likers.fetch()

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

    addAllActivity: (collection) =>

      visible = @findModelActivity collection

      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + i18nProperty.tenant_empty.activity + '</div>'

    findModelActivity: (collection) =>
      if collection instanceof ActivityList
        collection.select (a) =>
          a.get("property") and a.get("property").id is @model.id
      else 
        _.select collection, (a) =>
          a.get("property") and a.get("property").id is @model.id

    findModelComments: (collection) =>
      if collection instanceof CommentList
        collection.select (c) =>
          c.get("property") and c.get("property").id is @model.id
      else 
        _.select collection, (c) =>
          c.get("property") and c.get("property").id is @model.id

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
