define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  'collections/ActivityList'
  'collections/CommentList'
  'models/Activity'
  "models/Comment"
  "views/helper/Alert"
  "views/listing/Search"
  "views/activity/New"
  "views/activity/BaseIndex"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/following'
  'templates/activity/summary'
  'templates/activity/modal'
  'templates/comment/summary'
  # 'masonry'
  # 'jqueryui'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Activity, Comment, Alert, ListingSearchView, NewActivityView, BaseIndexActivityView, i18nListing, i18nCommon) ->

  class FollowingIndexView extends BaseIndexActivityView
  
    el: "#main"

    events:
      # 'click .pagination > ul > li > a'       : 'changePage'
      'click .thumbnails a.content'             : 'getModelDataToShowInModal'
      'click .thumbnails button.get-comments'   : 'getActivityCommentsAndCollection' # 'showModal'
      "mouseover .thumbnails .activity"         : "highlightMarkerFromCard"
      "mouseout .thumbnails .activity"          : "unhighlightMarkerFromCard"
      # 'hide #view-content-modal'              : 'hideModal'
      # 'click #view-content-modal .caption a'  : 'closeModal'
      # 'click #view-content-modal .left'       : 'prevModal'
      # 'click #view-content-modal .right'      : 'nextModal'
      # Activity events
      "click .like-button"                      : "likeOrLoginFromActivity"
      "click .likers"                           : "getLikersFromActivity"
      "submit form.new-comment-form"            : "getCommentDataToPost"
    
    initialize : (attrs) =>

      # Activity that we find on the map.
      Parse.User.current().get("profile").followingActivity || Parse.User.current().get("profile").followingActivity = new ActivityList [], {}
      Parse.User.current().get("profile").followingComments || Parse.User.current().get("profile").followingComments = new CommentList [], {}

      super

      @time = null            # Create a timer to buffer window re-draws.
      @mapId = "mapCanvas"
      @onMap = true
      
      # Listen to 
      @listenTo Parse.User.current().get("profile").followingActivity, "reset", @addAllActivity
      @listenTo Parse.User.current().get("profile").followingActivity, "add", @addOneActivity

      # Better off to use addAllComments manually.
      @listenTo Parse.User.current().get("profile").followingComments, "reset", @addAllComments

    render : ->
      vars = 
        today: moment().format("L")
        i18nListing: i18nListing
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/activity/following.jst"](vars)

      @$list = @$(".content > .thumbnails")
      if @$list.width() < 767 then @$list.html '<div class="list-view col-md-12"></div>'
      else @$list.html '<div class="list-view col-md-6"></div><div class="list-view col-md-6"></div>'
      
      @$listViews = @$list.find('.list-view')
      @$listViews.each (i, el) => @listViews[i] = new infinity.ListView @$(el), 
        lazy: ->
          pageId = Number $(this).attr(infinity.PAGE_ID_ATTRIBUTE)
          page = infinity.PageRegistry.lookup pageId
          _.each page.items, (item, index) ->
            return if item.loaded
            item.$el.data "pageIndex", index
            data = item.$el.data()
            if data.image then item.$el.find(".content .photo img").prop 'src', data.image
            if data.profile then item.$el.find("footer img.profile-pic").prop 'src', data.profile
            unless item.marker
              originY = if data.collection is "user" then 25 else 0

              item.marker = new google.maps.Marker
                position: new google.maps.LatLng data.lat, data.lng
                map: _this.map
                ZIndex: 1
                pageIndex: index
                pageId: pageId
                $ref: item.$el
                highlightCard: _this.highlightCard
                highlightMarker: _this.highlightMarker
                unhighlightCard: _this.unhighlightCard
                unhighlightMarker: _this.unhighlightMarker
                animation: google.maps.Animation.DROP
                icon: 
                  url: "/img/icon/pins-sprite.png"
                  size: new google.maps.Size(25, 32, "px", "px")
                  origin: new google.maps.Point(originY, (data.index % 20) * 32)
                  anchor: null
                  scaledSize: null
            
            if data.collection is "external"
              # Always add the listeners.
              item.highlightListener = google.maps.event.addListener item.marker, "mouseover", _this.highlightCardFromMarker
              item.unhighlightListener = google.maps.event.addListener item.marker, "mouseout", _this.unhighlightCardFromMarker

            item.loaded = true

        # Called when scrolling down on page stash.
        stash: ->
          page = infinity.PageRegistry.lookup $(this).attr(infinity.PAGE_ID_ATTRIBUTE)
          _.each page.items, (item) ->
            # item.marker.setAnimation null
            if item.marker and item.$el.data("collection") is "external"
              item.marker.setVisible false
              google.maps.event.removeListener item.highlightListener
              google.maps.event.removeListener item.unhighlightListener

        # Called when scrolling up through pages.
        add: ->
          page = infinity.PageRegistry.lookup $(this).attr(infinity.PAGE_ID_ATTRIBUTE)
          _.each page.items, (item) ->
            if item.$el.data("collection") is "external"
              item.marker.setAnimation google.maps.Animation.DROP
              item.marker.setVisible true
              # Always add the listeners.
              item.highlightListener = google.maps.event.addListener item.marker, "mouseover", _this.highlightCardFromMarker
              item.unhighlightListener = google.maps.event.addListener item.marker, "mouseout", _this.unhighlightCardFromMarker

      # @$list.masonry
      #   selector : 'li'
      #   columnWidth: (containerWidth) -> containerWidth / 2

      # @$pagination = @$(".content > .pagination ul")
      @$loading = @$(".content > .loading")

      # Record our fixed block.
      @$block = @$('#map-container')

      @getPersonalizedMapCenter()
      @renderMap()

      # Track scrolling & resizing for map
      $(window).resize @resize
      $(document.documentElement).resize @resize
      $(window).scroll @mapTracker
      $(document.documentElement).scroll @mapTracker

      # Track scrolling for infinity
      $(window).scroll @loadTracker
      $(document.documentElement).scroll @loadTracker
      @

    getPersonalizedMapCenter : =>
      if Parse.User.current()
        if Parse.User.current().get("property")
          @center = Parse.User.current().get("property").GPoint()
          @radius = 50000

        else if Parse.User.current().get("network")
          Parse.User.current().get("network").properties.getSetting()
          @center = Parse.User.current().get("network").properties.GPoint()
          @radius = Parse.User.current().get("network").properties.radius

        else
          @center = new google.maps.LatLng 43.6481, -79.4042
          @radius = 50000

      else
        @center = new google.maps.LatLng 43.6481, -79.4042
        @radius = 50000

    # createQueries : ->
    #   Parse.User.current().get("profile").followingActivity.query.matchesQuery "profile", Parse.User.current().get("profile").relation("following").query()
    #   Parse.User.current().get("profile").followingActivity.query.include("property")

    #   Parse.User.current().get("profile").followingComments.query.matchesQuery "profile", Parse.User.current().get("profile").relation("following").query()

    renderMap : =>
      if @radius
        if @radius > 1000000 then zoom = 3
        else if @radius > 700000 then zoom = 4
        else if @radius > 400000 then zoom = 5
        else if @radius > 200000 then zoom = 6
        else if @radius > 72500 then zoom = 8
        else if @radius > 35000 then zoom = 9
        else if @radius > 18800 then zoom = 10
        else if @radius > 9300 then zoom = 11
        else if @radius > 4600 then zoom = 12
        else zoom = 13
      else
        # Default zoom for when we move the map.
        zoom = 10

      @map = new google.maps.Map document.getElementById(@mapId), 
        zoom              : zoom
        center            : @center
        mapTypeId         : google.maps.MapTypeId.ROADMAP
        mapTypeControl    : false
        streetViewControl : false

      # Add listeners
      # @createQueries()
      @bindMapPosition()
      # @dragListener = google.maps.event.addListener @map, 'dragend', => @trigger "dragend"
      # @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch

      # Do a new search unless we've been here before.
      unless Parse.User.current().get("profile").followingActivity.length > 0
        @search()
      else

        # Protect ourselves from old models.
        Parse.User.current().get("profile").followingActivity.query.notContainedIn "objectId", Parse.User.current().get("profile").followingActivity.map((a) -> a.id)
        Parse.User.current().get("profile").followingComments.query.notContainedIn "objectId", Parse.User.current().get("profile").followingComments.map((c) -> c.id)

        # Show the activities
        @addAllActivity()
        @addAllComments Parse.User.current().get("profile").followingComments


    # Search functions
    # ----------------

    search : =>

      @$loading.html "<img src='/img/misc/spinner.gif' class='spinner' alt='#{i18nCommon.verbs.loading}' />"
      @moreToDisplay = true

      Parse.User.current().get("profile").followingActivity.query.skip(@resultsPerPage * (@page - 1)).limit(@resultsPerPage).include("property").include("profile")
      Parse.User.current().get("profile").followingComments.query.skip(@commentsPerPage * (@page - 1)).limit(@commentsPerPage).include("property").include("profile")

      # handleMapActivity
      Parse.Promise.when(
        Parse.User.current().get("profile").followingActivity.query.find(),
        Parse.User.current().get("profile").followingComments.query.find()
      ).then (objs, comms) =>

        if Parse.User.current() and Parse.User.current().get("network")
          pids = Parse.User.current().get("network").properties.map((p) -> p.id)

        if objs
          Parse.User.current().get("profile").followingActivity.add objs

          if objs.length < @resultsPerPage then @trigger "view:exhausted"
        else 
          if Parse.User.current().get("profile").followingActivity.length > 0 or (Parse.User.current() and Parse.User.current().get("profile").followingActivity.length > 0)
            @trigger "view:exhausted" 
          else @trigger "view:empty"
          
        if comms
          addedComms = Parse.User.current().get("profile").followingComments.add comms
        @addAllComments addedComms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount


      # Save the hassle of updatePaginiation on the first go-round.
      # We can infer whether we need it the second time around.
      if @page is 2 then @updatePaginiation()

    checkIfEnd : =>
      if Parse.User.current().get("profile").followingActivity.length >= @activityCount then @trigger "view:exhausted"


    likeOrLoginFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = Parse.User.current().get("profile").followingActivity.at(data.index)

      if Parse.User.current()
        @like model, activity, button, data
      else
        $("#signup-modal").modal()

    getLikersFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = Parse.User.current().get("profile").followingActivity.at(data.index)

      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikers
      model.likers.fetch()

    # App Activity
    # ------------

    checkIfLiked: (activity) =>
      data = activity.data()
      model = Parse.User.current().get("profile").followingActivity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    resetListViews: ->

      super
      @resetAppActivity()
      @resetUserActivity() if Parse.User.current()

    resetAppActivity: ->

      Parse.User.current().get("profile").followingActivity.reset()
      Parse.User.current().get("profile").followingComments.reset()
      # @$list.find('> li.empty').remove()

    # Add all items in the Properties collection at once.
    addAllActivity: (collection, filter) =>
      Parse.User.current().get("profile").followingActivity.each @addOneActivity if Parse.User.current().get("profile").followingActivity.length > 0

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parent().data()
      # Keep track of where we are, for subsequent navigation.
      @modalIndex = data.index

      @modalCollection = Parse.User.current().get("profile").followingActivity
      @modalCommentCollection = Parse.User.current().get("profile").followingComments

      @showModal()


    getCommentDataToPost: (e) ->
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = Parse.User.current().get("profile").followingActivity.at(data.index)

      @postComment activity, model


    getActivityCommentsAndCollection : (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()

      model = Parse.User.current().get("profile").followingActivity.at(data.index)
      comments = Parse.User.current().get("profile").followingComments

      button.button("loading")

      @getActivityComments(model, comments).then (newComms) =>
        addedComms = comments.add newComms
        @addAllComments addedComms
        button.button("reset")
      , =>
        button.button("reset")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'danger'

        
    addCommentToCollection : (comment) =>
      Parse.User.current().get("profile").followingComments.add comment




    # Update the pagination with appropriate count, pages and page numbers 
    updatePaginiation : =>

      countQuery = new Parse.Query("Activity")
      countQuery._where = _.clone Parse.User.current().get("profile").followingActivity._where
      countQuery.limit(-1).skip(0)

      countQuery.count().then (count) =>
        # remaining pages
        @activityCount = count
        @pages = Math.ceil((count)/ @resultsPerPage)

        if count is 0 then @trigger "view:empty"
        else @checkIfEnd()
          
        #   @renderPaginiation()
    
    # MAP
    # ----------

    bindMapPosition: => @$block.original_position = @$block.offset()
    
    # Track positioning and visibility.
    mapTracker: =>
      # Ensure minimum time between adjustments.
      return if @mapTime
      @mapTime = setTimeout =>

        # Track position relative to the viewport and set position.
        vOffset = (document.documentElement.scrollTop or document.body.scrollTop)

        # Take the top padding into account.
        vOffset += 60 # 40 navBar + 20 padding
        
        if vOffset > @$block.original_position.top
          @$block.addClass "float-block-fixed"
        else
          @$block.removeClass "float-block-fixed"

        # Reset timer
        @mapTime = null
      , 150
  
    # Track resizing.
    resize : =>

      # Ensure minimum time between adjustments.
      return if @time
      @time = setTimeout =>

        # Reset the block and calculate new position
        @$block.removeClass "float-block-fixed"
        @bindMapPosition()

        @mapTracker()

        # Reset timer
        @time = null
      , 250

    undelegateEvents : =>

      super

      # Break
      # @off "model:viewDetails"
      # @off "dragend"
      # @off "view:change"

      _.each @listViews, (lv) -> lv.cleanup()
      @detachModalEvents() if @modal

      $(window).off "resize scroll"
      $(document.documentElement).off "resize scroll"
      # google.maps.event.removeListener @dragListener
      # google.maps.event.removeListener @zoomListener

    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this


    highlightMarkerFromCard : (e) ->
      $ref = $(e.currentTarget)
      page = infinity.PageRegistry.lookup $ref.parent().attr(infinity.PAGE_ID_ATTRIBUTE)
      pageIndex = $ref.data().pageIndex

      @highlightCard $ref
      @highlightMarker page.items[pageIndex].marker

    unhighlightMarkerFromCard : (e) ->
      $ref = $(e.currentTarget)
      page = infinity.PageRegistry.lookup $ref.parent().attr(infinity.PAGE_ID_ATTRIBUTE)
      pageIndex = $ref.data().pageIndex

      @unhighlightCard $ref
      @unhighlightMarker page.items[pageIndex].marker

    highlightCardFromMarker : (e) ->
      page = infinity.PageRegistry.lookup this.pageId
      pageIndex = this.pageIndex

      this.highlightCard this.$ref
      this.highlightMarker page.items[pageIndex].marker

    unhighlightCardFromMarker : (e) ->
      page = infinity.PageRegistry.lookup this.pageId
      pageIndex = this.pageIndex

      this.unhighlightCard this.$ref
      this.unhighlightMarker page.items[pageIndex].marker


    highlightCard : ($ref) => $ref.addClass('active')
    unhighlightCard : ($ref) => $ref.removeClass('active')
    highlightMarker : (marker) -> 
      marker.icon.origin = new google.maps.Point(marker.icon.origin.x + 25, marker.icon.origin.y)
      marker.setIcon marker.icon
    unhighlightMarker : (marker) ->
      marker.icon.origin = new google.maps.Point(marker.icon.origin.x - 25, marker.icon.origin.y)
      marker.setIcon marker.icon