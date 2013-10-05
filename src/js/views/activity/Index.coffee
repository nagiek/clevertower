define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  'collections/ActivityList'
  'collections/CommentList'
  "models/Comment"
  "views/listing/Search"
  "views/activity/New"
  "views/activity/BaseIndex"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'templates/activity/summary'
  'templates/activity/modal'
  'templates/comment/summary'
  # 'masonry'
  # 'jqueryui'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Comment, ListingSearchView, NewActivityView, BaseIndexActivityView, i18nListing, i18nCommon) ->

  class ActivityIndexView extends BaseIndexActivityView
  
    el: "#main"

    events:
      'click #filters > button'                 : 'changeFilter'
      'click #search-map'                       : 'searchMap'
      # 'click .pagination > ul > li > a'       : 'changePage'
      'click .thumbnails a.content'             : 'getModelDataToShowInModal'
      "mouseover .thumbnails .activity"         : "highlightMarkerFromCard"
      "mouseout .thumbnails .activity"          : "unhighlightMarkerFromCard"
      # 'hide #view-content-modal'              : 'hideModal'
      # 'click #view-content-modal .caption a'  : 'closeModal'
      # 'click #view-content-modal .left'       : 'prevModal'
      # 'click #view-content-modal .right'      : 'nextModal'
      # Activity events
      "click .like-button"                      : "likeOrLogin"
      "click .likers"                           : "getLikers"
      "submit form.new-comment-form"            : "getCommentDataToPost"
    
    initialize : (attrs) =>

      super

      @onMap
      @location = attrs.location || ""
      @locationAppend = if attrs.params.lat and attrs.params.lng then "?lat=#{attrs.params.lat}&lng=#{attrs.params.lng}" else ''
      @center = new google.maps.LatLng attrs.params.lat, attrs.params.lng if attrs.params.lat and attrs.params.lng

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        # Get the activity in the user properties.
        @prepUserActivity()

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
        unless @location is data.location
          @location = data.location
          @renderCity()
        @placesService.getDetails reference: data.reference, @googleSearch

      # Create a timer to buffer window re-draws.
      @time = null

      @mapId = "mapCanvas"

      # Activity that we find on the map.
      unless Parse.App.activity
        Parse.App.activity = new ActivityList [], {}
        Parse.App.activity.query
        .include("property")
        .containedIn("activity_type", ["new_property", "new_listing", "new_post"])

      unless Parse.App.comments
        Parse.App.comments = new CommentList [], {}

      @listenTo Parse.App.activity, "reset", @addAllActivity
      @listenTo Parse.App.activity, "add", @addOneActivity

      @listenTo Parse.App.comments, "reset", @addAllComments
      # @listenTo Parse.App.comments, "add", @addOneComment

    checkIfLiked: (activity) =>
      data = activity.data()

      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    resetListViews: ->

      super
      @resetAppActivity()

    resetAppActivity: ->

      Parse.App.activity.reset()
      Parse.App.comments.reset()
      @resetUserActivity() if Parse.User.current()
      # @$list.find('> li.empty').remove()

    filterCollections: ->
      # "Specific" filter
      Parse.App.activity.query.containedIn "activity_type", [@filter]
      Parse.User.current().activity.query.containedIn "activity_type", [@filter] if Parse.User.current()

      switch @filter
        when "new_listing" then @specificSearchControls = new ListingSearchView(view: @).render()

    resetFilters: ->
      Parse.App.activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"]
      Parse.User.current().activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"] if Parse.User.current()

    prepUserActivity : =>
      # Get the property from what we've already loaded.
      Parse.User.current().activity = new ActivityList [], {} unless Parse.User.current().activity
      Parse.User.current().comments = new CommentList [], {} unless Parse.User.current().comments
      
      # @listenTo Parse.User.current().comments, "reset", @addAllComments
      # @listenTo Parse.User.current().comments, "add", @addOneComment

      @listenTo Parse.User.current().activity, 'reset', @resetUserActivity
      # @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity

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

      @hideAllProperties()

    getUserActivity : ->
      # Add user activity and comments 
      if Parse.User.current().activity.length is 0 and Parse.User.current().comments.length is 0
        Parse.Promise.when(
          Parse.User.current().activity.query.find(),
          Parse.User.current().comments.query.find()
        ).then (objs, comms) =>
          if objs then Parse.User.current().activity.add objs
          # Reset the comments, to trigger bulk-add behaviour.
          if comms then Parse.User.current().comments.reset comms

    resetUserActivity : =>

      @hideAllProperties()

      # Handle User Activity
      if Parse.User.current()
        # Check if activity is visible or not.
        if Parse.User.current().get("property") 
          p = Parse.User.current().get("property") 
          if @withinBounds p.get("center") then @showProperty p else @hideProperty p
        else if Parse.User.current().get("network")
          Parse.User.current().get("network").properties.each (p) => 
            if @withinBounds p.get("center") then @showProperty p else @hideProperty p
        Parse.User.current().activity.each @addOnePropertyActivity
        @addAllComments Parse.User.current().comments



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
        else if Parse.User.current() and Parse.User.current().lastReference
          @placesService.getDetails reference: Parse.User.current().lastReference, @initWithCenter
        else if @location
          new Parse.Query("Search").descending("createdAt").equalTo("location", @location).first()
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

    renderCity : =>
      if _.contains _.keys(Parse.App.cities), @location
        desc = Parse.App.cities[@location].desc
        title = @location.substring 0, @location.indexOf("-")
        image = "/img/city/#{@location}.jpg"

        # FB Meta Tags
        $("head meta[property='og:description']").attr "content", desc
        $("head meta[property='og:url']").attr "content", window.location.href
        $("head meta[property='og:image']").attr "content", window.location.origin + image
        $("head meta[property='og:type']").attr "content", "clevertower:city"

        @$("#city").html """
          <div class="fade in" style="background-image: url('#{image}');">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <div class="row">
              <h1 class="col-md-3">#{title}</h1>
              <p class="col-md-6">#{desc}</p>
            </div>
          </div>
        """
      else 
        @$("#city").empty()

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
      @bindMapPosition()
      # @dragListener = google.maps.event.addListener @map, 'dragend', => @trigger "dragend"
      # @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch

      # Search once the map is ready.
      google.maps.event.addListenerOnce @map, 'idle', @performSearchWithinMap
      @getUserActivity() if Parse.User.current()

    initWithCenter : (place, status) =>
      @center = place.geometry.location if status is google.maps.places.PlacesServiceStatus.OK
      @radius = 50000
      @renderMap()

    googleSearch : (place, status) =>

      if status is google.maps.places.PlacesServiceStatus.OK

        # @center = place.geometry.location
        # @map.setCenter @center

        @map.fitBounds place.geometry.viewport

        # bounds = @map.getBounds()
        sw = place.geometry.viewport.getSouthWest()
        ne = place.geometry.viewport.getNorthEast()
        @sw = new Parse.GeoPoint sw.lat(), sw.lng()
        @ne = new Parse.GeoPoint ne.lat(), ne.lng()

        Parse.App.activity.setBounds @sw, @ne
        Parse.App.comments.setBounds @sw, @ne

        # Dump the collection if we are going somewhere different.
        # Parse.App.activity.reset() unless oldBounds.intersects newBounds

        @redoSearch()

    searchMap : =>
      center = @map.getCenter()
      @locationAppend = "?lat=#{center.lat()}&lng=#{center.lng()}"
      Parse.history.navigate "/outside" + (if @location then "/#{@location}" else "") + @locationAppend
      @performSearchWithinMap()

    performSearchWithinMap: =>

      bounds = @map.getBounds()
      @sw = new Parse.GeoPoint(bounds.getSouthWest().lat(), bounds.getSouthWest().lng())
      @ne = new Parse.GeoPoint(bounds.getNorthEast().lat(), bounds.getNorthEast().lng())
      Parse.App.activity.setBounds @sw, @ne
      Parse.App.comments.setBounds @sw, @ne

      @redoSearch()

    search : =>

      @$loading.html "<img src='/img/misc/spinner.gif' class='spinner' alt='#{i18nCommon.verbs.loading}' />"
      @moreToDisplay = true

      # handleMapActivity
      Parse.Promise.when(
        Parse.App.activity.query.skip(@resultsPerPage * (@page - 1)).limit(@resultsPerPage).find(),
        Parse.App.comments.query.skip(@commentsPerPage * (@page - 1)).limit(@commentsPerPage).find()
      ).then (objs, comms) =>
        if objs then Parse.App.activity.add objs
        if comms then Parse.App.comments.add comms
        @addAllComments comms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount and @userActivityCount


      # Save the hassle of updatePaginiation on the first go-round.
      # We can infer whether we need it the second time around.
      if @page is 2 then @updatePaginiation()
      

    checkIfEnd : =>

        # Check if we have hit the end.
        collectionLength = Parse.App.activity.length 

        if Parse.User.current()
          if Parse.User.current().get("property")
            collectionLength += if Parse.User.current().get("property").shown is true then Parse.User.current().activity.length else 0
          else if Parse.User.current().get("network")
            pCount = Parse.User.current().activity.countByProperty()
            Parse.User.current().get("network").properties.each (p) -> if pCount[p.id] and p.shown is true then collectionLength += pCount[p.id]

        if collectionLength >= @activityCount + @userActivityCount then @trigger "view:exhausted"




    # BaseIndex Linkers
    # ------------------

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parent().data()
      # Keep track of where we are, for subsequent navigation.
      @modalIndex = data.index
       
      @modalCollection = if data.collection is "user"
        Parse.User.current().activity
      else Parse.App.activity

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

      @postComment activity, data, model


    # Activity
    # --------

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
        item = new infinity.ListItem @renderTemplate(a, false, true, a.get("property").pos())
        item.marker = a.get("property").marker
        a.get("property").marker.items.push item
        @listViews[@shortestColumnIndex()].prepend item
      else
        # view = new ActivityView
        #   model: a
        #   view: @
        #   liked: false
        # # @listViews[@shortestColumnIndex()].prepend new infinity.ListItem view.render().$el
        @listViews[@shortestColumnIndex()].prepend @renderTemplate(a, false, false, a.pos())

    # Add all items in the Properties collection at once.
    addAllActivity: (collection, filter) =>
      Parse.App.activity.each @addOne if Parse.App.activity.length > 0

    addOnePropertyActivity: (a) =>
      # view = new ActivityView
      #   model: a
      #   # marker: a.get("property").marker
      #   pos: a.get("property").pos()
      #   view: @
      #   linkedToProperty: true
      #   liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id

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

        item = new infinity.ListItem @renderTemplate(a, a.liked(), true, a.get("property").pos())
        item.marker = a.get("property").marker

        a.get("property").marker.items.push item
        @listViews[@shortestColumnIndex()].append item

      # @$list.append view.render().el
    
    # Show activity where we have already loaded the property
    showProperty: (property) =>
      property.shown = true

    hideProperty: (property) =>
      property.shown = false
      _.each property.marker.items, (a) -> a.remove()

    hideAllProperties: =>
      # hide all properties
      if Parse.User.current().get("property")
        # Visibility counter
        Parse.User.current().get("property").shown = false

      else if Parse.User.current().get("network")

        # Visibility counter
        Parse.User.current().get("network").properties.each (p) -> p.shown = false

    # Update the pagination with appropriate count, pages and page numbers 
    updatePaginiation : =>
      countQuery = Parse.App.activity.query
      # Reset old filters
      countQuery.notContainedIn("objectId", [])
      # Limit of -1 means do not send a limit.
      countQuery.limit(-1).skip(0)
      counting = countQuery.count()

      if Parse.User.current() and (Parse.User.current().get("property") or Parse.User.current().get("network"))
        userCountQuery = Parse.User.current().activity.query
        # Limit of -1 means do not send a limit.
        userCountQuery.limit(-1).skip(0)

        if Parse.User.current().get("property")

          # Visibility counter
          if Parse.User.current().get("property").shown is true
            userCountQuery.containedIn "property", Parse.User.current().get("property")
            userCounting = userCountQuery.count()
          else 
            userCounting = undefined

        else if Parse.User.current().get("network")

          properties = Parse.User.current().get("network").properties.filter (p) -> p.shown is true
          userCountQuery.containedIn "property", properties
          userCounting = userCountQuery.count()

      else 
        userCounting = undefined
      
      Parse.Promise
      .when(counting, userCounting)
      .then (count, userCount) =>
        # remaining pages

        userCount = 0 unless userCount

        @activityCount = count
        @userActivityCount = userCount
        @pages = Math.ceil((count + userCount)/ @resultsPerPage)
        # @$pagination.html ""
        if count + userCount is 0 then @trigger "view:empty"

        @checkIfEnd()
          
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