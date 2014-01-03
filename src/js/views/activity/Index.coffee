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
  "views/location/Summary"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'templates/activity/summary'
  'templates/activity/modal'
  'templates/comment/summary'
  # 'masonry'
  # 'jqueryui'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Activity, Comment, Alert, ListingSearchView, NewActivityView, BaseIndexActivityView, LocationSummaryView, i18nListing, i18nCommon) ->

  class ActivityIndexView extends BaseIndexActivityView
  
    el: "#main"

    events:
      'change #filters input'                   : 'changeFilter'
      'click #search-map'                       : 'searchMap'
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

      super

      @time = null            # Create a timer to buffer window re-draws.
      @mapId = "mapCanvas"
      @onMap = true

      @location = attrs.location || ""
      if attrs.params.lat and attrs.params.lng 
        @locationAppend = "?lat=#{attrs.params.lat}&lng=#{attrs.params.lng}"
        @center = new google.maps.LatLng attrs.params.lat, attrs.params.lng

      # Activity that we find on the map.
      Parse.App.activity || Parse.App.activity = new ActivityList [], {}
      Parse.App.comments || Parse.App.comments = new CommentList [], {}
      
      # Listen to 
      @listenTo Parse.App.activity, "reset", @addAllActivity
      @listenTo Parse.App.activity, "add", @addOneActivity

      # Better off to use addAllComments manually.
      @listenTo Parse.App.comments, "reset", @addAllComments

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        # Get the activity in the user properties.
        @prepUserActivity()
        @createQueries()

        # Post view
        @newPostView = new NewActivityView(view: @).render()
        @listenTo @newPostView, "view:resize", @bindMapPosition
        @listenTo @newPostView, "model:save", @prependNewPost

      @listenTo Parse.Dispatcher, "user:logout", => 
        _.each @listViews, (lv) -> 
          _.each lv.pages, (page) ->
            _.each page.item, (item) ->
              if item.$el.data("collection") is "user"
                item.marker.setMap null
                google.maps.event.removeListener item.clickListener
                google.maps.event.removeListener item.highlightListener
                google.maps.event.removeListener item.unhighlightListener
                item.remove()


      @listenTo Parse.App.search, "google:search", (data) =>
        @location = data.googleName unless @location is data.googleName
        @placesService.getDetails reference: data.reference, @googleSearch


    render: ->
      vars = 
        today: moment().format("L")
        i18nListing: i18nListing
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/activity/index.jst"](vars)

      @renderCity()
      
      @$('[rel=tooltip]').tooltip placement: 'bottom'

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

      @placesService = new google.maps.places.PlacesService(document.getElementById(@mapId))

      if @center then @renderMap()
      else 
        if Parse.App.search.lastReference
          @placesService.getDetails reference: Parse.App.search.lastReference, @initWithCenter
        else if @location
          new Parse.Query("Search").descending("createdAt").equalTo("googleName", @location).first()
          .then (obj) => 
            if obj
              @placesService.getDetails reference: obj.get("reference"), @initWithCenter
            else 
              @getPersonalizedMapCenter()
              @renderMap()
          , =>
            @getPersonalizedMapCenter()
            @renderMap()
        else
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

    createQueries : ->
      # Set up query to match conditions
      if Parse.User.current()
        @activityQuery = Parse.Query.or(
          Parse.App.activity.query,
          Parse.User.current().activity.query
        )
        @commentQuery = Parse.Query.or(
          Parse.App.comments.query
          Parse.User.current().comments.query
        )
      else
        @activityQuery = Parse.App.activity.query
        @commentQuery = Parse.App.comments.query

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

      if Parse.User.current()
        @prepUserActivity()

        @newPostView = new NewActivityView(view: @).render()
        @listenTo @newPostView, "view:resize", @bindMapPosition
        @listenTo @newPostView, "model:save", @prependNewPost

      # Add listeners
      @createQueries()
      @bindMapPosition()
      # @dragListener = google.maps.event.addListener @map, 'dragend', => @trigger "dragend"
      # @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch

      # Do a new search unless we've been here before.
      unless Parse.App.activity.length > 0 or (Parse.User.current() and Parse.User.current().activity.length > 0)
        # Search once the map is ready.
        google.maps.event.addListenerOnce @map, 'idle', @performSearchWithinMap
      else

        # Protect ourselves from old models.
        ninActivity = Parse.App.activity.map((a) -> a.id)
        ninComments = Parse.App.comments.map((c) -> c.id)

        @activityQuery.notContainedIn "objectId", ninActivity
        @commentQuery.notContainedIn "objectId", ninComments

        # Show the activities
        @addAllActivity()
        @addAllComments Parse.App.comments

        if Parse.User.current()
          ninActivity = _.merge ninActivity, Parse.User.current().activity.map((a) -> a.id)
          ninComments = _.merge ninComments, Parse.User.current().comments.map((c) -> c.id)
          @addAllPropertyActivity()
          @addAllComments Parse.User.current().comments

    initWithCenter : (place, status) =>
      @center = place.geometry.location if status is google.maps.places.PlacesServiceStatus.OK
      @radius = 50000
      @renderMap()


    # Search functions
    # ----------------

    googleSearch : (place, status) =>

      if status is google.maps.places.PlacesServiceStatus.OK
        @renderCity()
        @map.fitBounds place.geometry.viewport
        @setBoundsAndSearch place.geometry.viewport.getSouthWest(), place.geometry.viewport.getNorthEast()

    searchMap : =>
      center = @map.getCenter()
      @locationAppend = "?lat=#{center.lat()}&lng=#{center.lng()}"
      Parse.history.navigate "/outside" + (if @location then "/#{@location}" else "") + @locationAppend
      @performSearchWithinMap()

    performSearchWithinMap : =>

      bounds = @map.getBounds()
      @setBoundsAndSearch bounds.getSouthWest(), bounds.getNorthEast()

    setBoundsAndSearch : (sw, ne) =>

      @sw = new Parse.GeoPoint(sw.lat(), sw.lng())
      @ne = new Parse.GeoPoint(ne.lat(), ne.lng())
      @activityQuery.withinGeoBox 'center', @sw, @ne
      @commentQuery.withinGeoBox 'center', @sw, @ne

      @redoSearch()

    search : =>

      @$loading.html "<img src='/img/misc/spinner.gif' class='spinner' alt='#{i18nCommon.verbs.loading}' />"
      @moreToDisplay = true

      @activityQuery.skip(@resultsPerPage * (@page - 1)).limit(@resultsPerPage).include("property").include("profile")
      @commentQuery.skip(@commentsPerPage * (@page - 1)).limit(@commentsPerPage).include("property").include("profile")

      # handleMapActivity
      Parse.Promise.when(
        @activityQuery.find(),
        @commentQuery.find()
      ).then (objs, comms) =>

        addedComms = []

        if Parse.User.current() and Parse.User.current().get("network")
          pids = Parse.User.current().get("network").properties.map((p) -> p.id)

        if objs
          for obj in objs
            if obj.get("property")
              if Parse.User.current()

                if Parse.User.current().get("network")
                  if _.contains pids, obj.get("property").id
                    Parse.User.current().activity.add obj
                  else Parse.App.activity.add obj

                else if Parse.User.current().get("property")
                  if obj.get("property").id is Parse.User.current().get("property").id
                    Parse.User.current().activity.add obj
                  else Parse.App.activity.add obj
                else Parse.App.activity.add obj
              else Parse.App.activity.add obj
            else Parse.App.activity.add obj

          if objs.length < @resultsPerPage then @trigger "view:exhausted"
        else 
          if Parse.App.activity.length > 0 or (Parse.User.current() and Parse.User.current().activity.length > 0)
            @trigger "view:exhausted" 
          else @trigger "view:empty"
          
        if comms 
          for comm in comms
            if comm.get("property")
              if Parse.User.current()

                if Parse.User.current().get("network")
                  if _.contains pids, comm.get("property").id
                    addedComms.push Parse.User.current().comments.add(comm)
                  else addedComms.push Parse.App.comments.add(comm)

                else if Parse.User.current().get("property")
                  if comm.get("property").id is Parse.User.current().get("property").id
                    addedComms.push Parse.User.current().comments.add(comm)
                  else addedComms.push Parse.App.comments.add(comm)
                else addedComms.push Parse.App.comments.add(comm)
              else addedComms.push Parse.App.comments.add(comm)
            else addedComms.push Parse.App.comments.add(comm)
        @addAllComments addedComms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount


      # Save the hassle of updatePaginiation on the first go-round.
      # We can infer whether we need it the second time around.
      if @page is 2 then @updatePaginiation()

    checkIfEnd : =>

        # Check if we have hit the end.
        collectionLength = Parse.App.activity.length 
        collectionLength += Parse.User.current().activity.length if Parse.User.current()

        # if Parse.User.current()
        #   if Parse.User.current().get("property")
        #     collectionLength += if Parse.User.current().get("property").shown is true then Parse.User.current().activity.length else 0
        #   else if Parse.User.current().get("network")
        #     pCount = Parse.User.current().activity.countByProperty()
        #     Parse.User.current().get("network").properties.each (p) -> if pCount[p.id] and p.shown is true then collectionLength += pCount[p.id]

        if collectionLength >= @activityCount then @trigger "view:exhausted"


    likeOrLoginFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      if Parse.User.current()
        @like model, activity, button, data, false
      else
        $("#signup-modal").modal()

    getLikersFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikers
      model.likers.fetch()


    # User activity
    # -------------

    prepUserActivity : =>
      # Get the property from what we've already loaded.
      Parse.User.current().activity || Parse.User.current().activity = new ActivityList [], {}
      Parse.User.current().comments || Parse.User.current().comments = new CommentList [], {}
      
      @listenTo Parse.User.current().comments, "reset", @addAllComments

      @listenTo Parse.User.current().activity, 'reset', @addallPropertyActivity
      @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity

      if Parse.User.current().get("property")
        # Activity list for *property*        
        Parse.User.current().activity.query.equalTo "property", Parse.User.current().get("property")
        Parse.User.current().comments.query.equalTo "property", Parse.User.current().get("property")

        Parse.App.activity.query.notEqualTo "property", Parse.User.current().get("property")
        Parse.App.comments.query.notEqualTo "property", Parse.User.current().get("property")

        Parse.User.current().get("property").marker = new google.maps.Marker
            position:   Parse.User.current().get("property").GPoint()
            map:        @map
            items:      []
            icon: 
              url: "/img/icon/pins-sprite.png"
              size: new google.maps.Size(25, 32, "px", "px")
              origin: new google.maps.Point(50, 0)
              anchor: null
              scaledSize: null
            ZIndex:     100
            url:        Parse.User.current().get("property").publicUrl()
            highlightCard: @highlightCard
            highlightMarker: @highlightMarker
            unhighlightCard: @unhighlightCard
            unhighlightMarker: @unhighlightMarker

          Parse.User.current().get("property").highlightListener = google.maps.event.addListener Parse.User.current().get("property").marker, "mouseover", @highlightCardsFromPropertyMarker
          Parse.User.current().get("property").unhighlightListener = google.maps.event.addListener Parse.User.current().get("property").marker, "mouseout", @unhhighlightCardsFromPropertyMarker
          Parse.User.current().get("property").clickListener = google.maps.event.addListener Parse.User.current().get("property").marker, "click", @goToPropertyFromPropertyMarker

      else if Parse.User.current().get("network")

        # Activity list for *network*
        Parse.User.current().activity.query.equalTo "network", Parse.User.current().get("network")
        Parse.User.current().comments.query.equalTo "network", Parse.User.current().get("network")

        Parse.App.activity.query.notEqualTo "network", Parse.User.current().get("network")
        Parse.App.comments.query.notEqualTo "network", Parse.User.current().get("network")

        Parse.User.current().get("network").properties.each (p) =>
            p.marker = new google.maps.Marker
              position:   p.GPoint()
              map:        @map
              ZIndex:     100
              url:        p.publicUrl()
              items:      []
              highlightCard: @highlightCard
              highlightMarker: @highlightMarker
              unhighlightCard: @unhighlightCard
              unhighlightMarker: @unhighlightMarker
              icon: 
                url: "/img/icon/pins-sprite.png"
                size: new google.maps.Size(25, 32, "px", "px")
                origin: new google.maps.Point(50, p.pos() * 32)
                anchor: null
                scaledSize: null

            p.highlightListener = google.maps.event.addListener p.marker, "mouseover", @highlightCardsFromPropertyMarker
            p.unhighlightListener = google.maps.event.addListener p.marker, "mouseout", @unhighlightCardsFromPropertyMarker
            p.clickListener = google.maps.event.addListener p.marker, "click", @goToPropertyFromPropertyMarker

      
      # Hide all properties at the start.
      # if Parse.User.current().get("property")
      #   Parse.User.current().get("property").shown = false
      # else if Parse.User.current().get("network")
      #   Parse.User.current().get("network").properties.each (p) -> p.shown = false # @hideProperty

    # Add all items in the Properties collection at once.
    addAllPropertyActivity: (collection, filter) =>
      Parse.User.current().activity.each @addOnePropertyActivity if Parse.User.current().activity.length > 0

    addOnePropertyActivity: (a) =>

      # We need the original property, for the position
      # within the collection, as well as for map markers.
      if Parse.User.current()
        if Parse.User.current().get("property")
          a.set "property", Parse.User.current().get("property")
        else if Parse.User.current().get("network")
          property = Parse.User.current().get("network").properties.find((p) -> p.id is a.get("property").id)
          a.set "property", property

      # item = new infinity.ListItem view.render().$el
      if ((!@filter or @filter is a.get("activity_type")) and (!@specificSearchControls or @specificSearchControls.filter(a)))

        item = new infinity.ListItem @renderTemplate(a, a.likedByUser(), true, true)
        item.marker = a.get("property").marker

        a.get("property").marker.items.push item
        @listViews[@shortestColumnIndex()].append item

      # @$list.append view.render().el
    
    # Show activity where we have already loaded the property
    # showProperty : (property) =>
    #   property.shown = true

    # hideProperty : (property) =>
    #   property.shown = false
    #   _.each property.marker.items, (a) -> a.remove()

    resetUserActivity : =>

    #   # Handle User Activity
    #   if Parse.User.current()
    #     # Check if activity is visible or not.
    #     if Parse.User.current().get("property") 
    #       p = Parse.User.current().get("property") 
    #       if @withinBounds p.get("center") then @showProperty p else @hideProperty p
    #     else if Parse.User.current().get("network")
    #       Parse.User.current().get("network").properties.each (p) => 
    #         if @withinBounds p.get("center") then @showProperty p else @hideProperty p

      Parse.User.current().activity.reset()
      Parse.User.current().comments.reset()

    # App Activity
    # ------------

    checkIfLiked: (activity) =>
      data = activity.data()

      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      @markAsLiked(activity) if model.likedByUser()

    checkIfFollowing: (activity) =>

      data = activity.data()

      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      @markAsFollowing(activity) if model.followedByUser()

    resetListViews: ->

      super
      @resetAppActivity()
      @resetUserActivity() if Parse.User.current()

    resetAppActivity: ->

      Parse.App.activity.reset()
      Parse.App.comments.reset()
      # @$list.find('> li.empty').remove()

    # Add all items in the Properties collection at once.
    addAllActivity: (collection, filter) =>
      Parse.App.activity.each @addOneActivity if Parse.App.activity.length > 0

    # BaseIndex Linkers
    # ------------------

    prependNewPost: (a) =>
      if a.get("property")
        # view = new ActivityView
        #   model: a
        #   # marker: a.get("property").marker
        #   pos: a.get("property").pos()
        #   view: @
        #   linkedToProperty: true
        #   liked: false
        # item = new infinity.ListItem view.render().$el
        item = new infinity.ListItem @renderTemplate(a, false, true, true)
        item.marker = a.get("property").marker
        a.get("property").marker.items.push item
        @listViews[@shortestColumnIndex()].prepend item
      else
        # view = new ActivityView
        #   model: a
        #   view: @
        #   liked: false
        # # @listViews[@shortestColumnIndex()].prepend new infinity.ListItem view.render().$el
        @listViews[@shortestColumnIndex()].prepend @renderTemplate(a, false, true, false)

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parent().data()
      # Keep track of where we are, for subsequent navigation.
      @modalIndex = data.index

      if data.collection is "user"
        @modalCollection = Parse.User.current().activity
        @modalCommentCollection = Parse.User.current().comments
      else 
        @modalCollection = Parse.App.activity
        @modalCommentCollection = Parse.App.comments

      @showModal()


    getCommentDataToPost: (e) ->
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      @postComment activity, model


    getActivityCommentsAndCollection : (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      if data.collection is "user"
        model = Parse.User.current().activity.at(data.index)
        comments = Parse.User.current().comments
      else 
        model = Parse.App.activity.at(data.index)
        comments = Parse.App.comments

      button.button("loading")

      @getActivityComments(model, comments).then (newComms) =>
        addedComms = comments.add newComms
        @addAllComments addedComms
        button.button("reset")
      , =>
        button.button("reset")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'danger'

        
    addCommentToCollection : (comment) =>
      if Parse.User.current().get("property")
        if comment.get("property") and comment.get("property").id is Parse.User.current().get("property").id
          Parse.User.current().comments.add comment
        else Parse.App.comments.add comment
      else if Parse.User.current().get("network")
        if comment.get("property") and Parse.User.current().get("network").properties.find((p) -> p.id is comment.get("property").id)
          Parse.User.current().comments.add comment
        else Parse.App.comments.add comment
      else Parse.App.comments.add comment 


    # Modal functions
    # ----------------

    showModal : =>

      super

      # Trigger a search if we click on a location.
      $('#view-content-modal').on 'click', 'a.location-link', @gotoLocation

    gotoLocation: (e) =>
      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]
      location = model.get("location").slug()
      unless @location is location
        @location = location
        new Parse.Query("Search").descending("createdAt").equalTo("googleName", location).first()
          .then (obj) => 
            console.log obj
            if obj then @placesService.getDetails reference: obj.get("reference"), @googleSearch
          (error) => console.log error


    # Filter functions
    # ----------------

    changeFilter: (e) ->
      e.preventDefault()
      
      filter = e.currentTarget.id
      if filter is "all" then filter = ""
      return if filter is @filter
      @filter = filter
      @specificSearchControls.clear() if @specificSearchControls

      if @filter then @filterCollections() else @resetFilters()

      @redoSearch()

    filterCollections: ->
      # "Specific" filter
      Parse.App.activity.query.containedIn "activity_type", [@filter]
      Parse.User.current().activity.query.containedIn "activity_type", [@filter] if Parse.User.current()

      switch @filter
        when "new_listing" then @specificSearchControls = new ListingSearchView(view: @).render()

    resetFilters: ->
      Parse.App.activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"]
      Parse.User.current().activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"] if Parse.User.current()

# Update the pagination with appropriate count, pages and page numbers 
    updatePaginiation : =>

      countQuery = new Parse.Query("Activity")
      countQuery._where = _.clone @activityQuery._where
      countQuery.limit(-1).skip(0)

      # if Parse.User.current() and (Parse.User.current().get("property") or Parse.User.current().get("network"))
      #   userCountQuery = Parse.User.current().activity.query
      #   # Limit of -1 means do not send a limit.
      #   userCountQuery.limit(-1).skip(0)

      #   if Parse.User.current().get("property")

      #     # Visibility counter
      #     if Parse.User.current().get("property").shown is true
      #       userCountQuery.containedIn "property", Parse.User.current().get("property")
      #       userCounting = userCountQuery.count()
      #     else 
      #       userCounting = undefined

      #   else if Parse.User.current().get("network")

      #     properties = Parse.User.current().get("network").properties.filter (p) -> p.shown is true
      #     userCountQuery.containedIn "property", properties
      #     userCounting = userCountQuery.count()

      # else 
      #   userCounting = undefined
      
      # Parse.Promise
      # .when(counting,)

      countQuery.count().then (count) =>
        # remaining pages
        @activityCount = count
        @pages = Math.ceil((count)/ @resultsPerPage)

        if count is 0 then @trigger "view:empty"
        else @checkIfEnd()
          
        #   @renderPaginiation()
    
    # MAP
    # ----------

    renderCity : =>
      location = Parse.App.locations.find((l) => l.get("googleName") is @location)
      if location
        @city = new LocationSummaryView(model: location, view: @).render()
      else 
        @city.clear() if @city


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

        @bindMapPosition() unless @$block.original_position
        
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

    withinBounds : (center) =>

      lat = center.latitude
      lng = center.longitude

      # Determine if it is within the box.
      @sw.latitude < lat and
        lat < @ne.latitude and 
        @sw.longitude < lng and 
        lng < @ne.longitude

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

    highlightCardsFromPropertyMarker : ->
      _.each this.items, (item) => this.highlightCard item.$el
      this.highlightMarker this # page.items[pageIndex].marker

    unhighlightCardsFromPropertyMarker : ->
      _.each this.items, (item) => this.unhighlightCard item.$el
      this.unhighlightMarker this # page.items[pageIndex].marker

    goToPropertyFromPropertyMarker : -> Parse.history.navigate this.url, true

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