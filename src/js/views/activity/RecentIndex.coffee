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
      'click .thumbnails a.content'             : 'showModal'
      "mouseover .thumbnails .activity"         : "highlightMarkerFromCard"
      "mouseout .thumbnails .activity"          : "unhighlightMarkerFromCard"
      # 'hide #view-content-modal'              : 'hideModal'
      # 'click #view-content-modal .caption a'  : 'closeModal'
      # 'click #view-content-modal .left'       : 'prevModal'
      # 'click #view-content-modal .right'      : 'nextModal'
      # Activity events
      "click .like-button"                      : "likeOrLogin"
      "click .likers"                           : "getLikers"
      "submit form.new-comment-form"            : "postComment"
    
    initialize : (attrs) =>

      super

      @location = attrs.location || ""
      @locationAppend = if attrs.params.lat and attrs.params.lng then "?lat=#{attrs.params.lat}&lng=#{attrs.params.lng}" else ''
      @page = attrs.params.page || 1
      @center = new google.maps.LatLng attrs.params.lat, attrs.params.lng if attrs.params.lat and attrs.params.lng
      @updateScheduled = false
      @moreToDisplay = true

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        # Check for likes.
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkForLikes
        # Get the activity in the user properties.
        @prepUserActivity()
        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()
        # Post view
        @newPostView = new NewActivityView(view: @).render()
        @listenTo @newPostView, "view:resize", @bindMapPosition
        @listenTo @newPostView, "model:save", @prependNewPost

        # Add comment bar
        _.each @listViews, (lv) -> 
          _.each lv.pages, (page) ->
            _.each page.item, (item) ->
              if item.$el.find(".comments").append
                """
                <form class="new-comment-form form-condensed">
                  <div class="form-group">
                    <div class="photo photo-micro pull-left">
                      <img src="#{Parse.User.current().get("profile").cover("tiny")}" alt="#{Parse.User.current().get("profile").name()}" width="23" height="23">
                    </div>
                    <div class="photo-float micro-float">
                      <input type="text" class="comment-title form-control input-sm" name="comment[title]" placeholder="<%= i18nCommon.actions.add_comment %>">
                    </div>
                  </div>
                </form>
                """

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

      @on "model:view", @showModal
      # @on "dragend", @handleMapMove
      @on "view:change", @clear

      @on "view:exhausted", =>
        @moreToDisplay = false
        @$loading.html i18nCommon.activity.exhausted

      @on "view:empty", =>
        @moreToDisplay = false
        @$loading.html i18nListing.listings.empty.index

      # Create a timer to buffer window re-draws.
      @time = null

      @mapId = "mapCanvas"

      @resultsPerPage = 20
      @commentsPerPage = 40
      # The chunkSize is the number of pages displayed in a group
      @chunkSize = 10
      # The chunk is the start of the group of pages we are displaying
      @chunk = Math.floor(@page / @resultsPerPage) + 1

      # Activity that we find on the map.
      unless Parse.App.activity
        Parse.App.activity = new ActivityList [], {}
        Parse.App.activity.query
        .include("property")
        .containedIn("activity_type", ["new_property", "new_listing", "new_post"])

      unless Parse.App.comments
        Parse.App.comments = new CommentList [], {}

      @listenTo Parse.App.activity, "reset", @addAll
      @listenTo Parse.App.activity, "add", @addOne

      @listenTo Parse.App.comments, "reset", @addAllComments
      # @listenTo Parse.App.comments, "add", @addOneComment

      if Parse.User.current()
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkForLikes

        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()

    checkForLikes: ->
      Parse.User.current().get("profile").likes.each (l) =>
        _.each @listViews, (lv) =>
          activity = lv.find("#activity-#{l.id}")
          if activity.length > 0
            @markAsLiked activity[0].$el
            # return false to avoid checking the other column.
            false

    resetListViews: ->

      # Clean up old stuff
      _.each @listViews, (lv) -> lv.reset()
      @resetAppActivity()

    resetAppActivity: ->

      Parse.App.activity.reset()
      Parse.App.comments.reset()
      @resetUserActivity() if Parse.User.current()
      # @$list.find('> li.empty').remove()


    # refreshDisplay : ->
    #   Parse.App.activity.each (a) -> a.trigger "refresh"
    #   if Parse.User.current() and Parse.User.current().activity
    #     Parse.User.current().activity.each (a) -> a.trigger "refresh" 
    #   # @$list.masonry 'reload'

    changeFilter: (e) ->
      e.preventDefault()
      
      btn = @$(e.currentTarget)
      filter = btn.data "filter"
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
      
      @listViews = []
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

      # Add user activity and comments 
      Parse.Promise.when(
        Parse.User.current().activity.query.find(),
        Parse.User.current().comments.query.find()
      ).then (objs, comms) =>
        if objs then Parse.User.current().activity.add objs
        # Reset the comments, to trigger bulk-add behaviour.
        if comms then Parse.User.current().comments.reset comms


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

    redoSearch : =>

      @chunk = 1
      @page = 1

      @resetListViews()
      @search()
      @updatePaginiation()

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



    # Adding from Collections
    # -----------------------

    renderTemplate: (model, liked, linked, pos) =>

      # Create new element with extra details for infinity.js
      if linked
        collection = "user"
        propertyId = model.get("property").id
        propertyIndex = model.get("property").pos()
      else
        collection = "external"
        propertyId = false
        propertyIndex = false

      $el = $ """
      <div class="thumbnail clearfix activity fade in"
        id="activity-#{model.id}"
        data-liked="#{liked}"
        data-property-index="#{propertyIndex}" 
        data-property-id="#{propertyId}"
        data-index="#{model.pos()}"
        data-lat="#{model.GPoint().lat()}"
        data-lng="#{model.GPoint().lng()}"
        data-collection="#{collection}"
        data-profile="#{model.profilePic("tiny")}"
        data-image="#{model.image("large")}"
      />
      """

      vars = _.merge model.toJSON(), 
        url: model.url()
        pos: pos % 20 # This will be incremented in the template.
        linkedToProperty: linked
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        postImage: model.image("large") # Keep this in for template logic.
        profileUrl: model.get("profile").url()
        liked: liked
        icon: model.icon()
        name: model.name()
        current: Parse.User.current()
        i18nCommon: i18nCommon

      if Parse.User.current()
        vars.self = Parse.User.current().get("profile").name()
        vars.selfProfilePic = Parse.User.current().get("profile").cover("tiny")

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likeCount: 0
        commentCount: 0

      # Override default title.
      vars.title = model.title()

      $el.html JST["src/js/templates/activity/summary.jst"](vars)

      @checkIfLiked($el) if Parse.User.current() and not liked

      $el

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

    addOne: (a) =>
      # view = new ActivityView
      #   model: a
      #   view: @
      #   liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
      # @listViews[@shortestColumnIndex()].append view.render().$el
      @listViews[@shortestColumnIndex()].append @renderTemplate(a, a.liked(), false, a.pos())
      # @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
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

    # Pagination
    # ----------

    # Find the shortest column.
    # Returns the infinity.ListView
    shortestColumnIndex: ->
      return 0 if @listViews.length is 1
      minIndex = 0
      minHeight = 0
      @$listViews.each (i, el) => 
        $currCol = @$(el)
        if i is 0 then minHeight = $currCol.height()
        else if minHeight > $currCol.height() then minIndex = i; minHeight = $currCol.height()
      return minIndex

    endOfDocument: ->
      viewportBottom = $(window).scrollTop() + $(window).height()
      @$loading.offset().top <= viewportBottom

    loadTracker: =>
      if(!@updateScheduled and @moreToDisplay)
        setTimeout =>
          if @endOfDocument() then @nextPage()
          @updateScheduled = false
        , 1000
        @updateScheduled = true

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
          
    
    # renderPaginiation : (e) =>

    #   pages = @pages - @chunk + 1

    #   if pages > @chunkSize then pages = @chunkSize; next = true

    #   if @chunk > 1 then @$pagination.append "<li><a href='#' class='prev' data-page='prev'>...</a></li>"

    #   url = "/search/#{@location}" 
    #   for page in [@chunk..@chunk + pages - 1] by 1
    #     if page > 1
    #       append = @locationAppend + (if @locationAppend.length > 0 then "&" else "?") + "page=#{page}"
    #     else 
    #       append = @locationAppend
    #     @$pagination.append "<li><a data-page='#{page}' href='#{url}#{append}'>#{page}</a></li>"
    #   if next then @$pagination.append "<li><a href='#' class='next' data-page='next'>...</a></li>"

    #   if @chunk <= @page and @page < @chunk + @chunkSize
    #     # @chunk > 1 means that prev chunks exist, and a prev button is displayed
    #     n = @page - @chunk + 1 + if @chunk > 1 then 1 else 0
    #     @$pagination.find(":nth-child(#{n})").addClass('active')


    # # Change the page within the current pagination.
    # changePage : (e) =>
    #   e.preventDefault()
    #   selected = e.currentTarget.attributes["data-page"].value

    #   if selected is 'next' or selected is 'prev'
    #     # Change the chunk
    #     @chunk = if selected is 'next' then @chunk + @chunkSize else @chunk - @chunkSize
    #     @renderPaginiation()
        
    #   else
    #     # Change the page within the chunk
    #     @page = selected
    #     @$pagination.find("li > .active").removeClass('active')

    #     n = Math.round(@page / @chunkSize) + if @chunk > 1 then 1 else 0
    #     @$pagination.find(":nth-child(#{n})").addClass('active')
        
    #     Parse.App.activity.query.skip(@resultsPerPage * (@page - 1))

    #     # Reset and get new
    #     Parse.App.activity.reset()
    #     @search()

    # Change the page within the current pagination.
    nextPage : =>
      @page += 1
      @search()


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
      super

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


    # Activity
    # --------------

    likeOrLogin: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      likes = Number activity.find(".like-count").html()
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      if Parse.User.current()
        if data.liked
          button.removeClass "active"
          activity.find(".like-count").html(likes - 1)
          activity.find(".likers").removeClass "active"
          activity.find(".like-button").text i18nCommon.verbs.like
          activity.data "liked", false
          # activity.attr "data-liked", "false"
          model.increment likeCount: -1
          model.relation("likers").remove Parse.User.current().get("profile")
          Parse.User.current().get("profile").relation("likes").remove model
          Parse.User.current().get("profile").likes.remove model
        else
          button.addClass "active"
          activity.find(".like-count").html(likes + 1)
          @markAsLiked(activity)
          model.increment likeCount: +1
          model.relation("likers").add Parse.User.current().get("profile")
          Parse.User.current().get("profile").relation("likes").add model
          # Adding to a relation will somehow add to collection..?
          Parse.User.current().get("profile").likes.add model
        Parse.Object.saveAll [model, Parse.User.current().get("profile")]
      else
        $("#signup-modal").modal()

    getLikers: (e) ->
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      likes = Number activity.find(".like-count").html()
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikers
      model.likers.fetch()

    showLikers: (collection) ->
      # visible = collection
      # .chain()
      # .select((c) => c.get("activity") and c.get("activity").id is model.id)
      # .map((c) => c.get("profile"))
      # .value()

      if collection.length > 0
        # profiles = _.uniq(visible, false, (v) -> v.id)
        $("#people-modal .modal-body").html "<ul class='list-unstyled' />"
        collection.each (p) ->
          $("#people-modal .modal-body ul").append """
            <li class="clearfix">
              <div class="photo photo-thumbnail pull-left">
                <a href="#{p.url()}">
                  <img src="#{p.cover("thumb")}" height="50" width="50">
                </a>
              </div>
              <div class="photo-float thumbnail-float">
                <h4><a href="#{p.url()}">#{p.name()}</a></h4>
              </div>
            </li>
          """
        $("#people-modal").modal()
        
      else
        $("#people-modal .modal-body ul").append """
          <li>Be the first one to like this</li>
        """

    checkIfLiked: (activity) =>
      data = activity.data()

      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    # Used just for display, not the action.
    markAsLiked: (activity) =>
      activity.find(".likers").addClass "active"
      activity.find(".like-button").text i18nCommon.adjectives.liked
      activity.data "liked", true
      # activity.attr "data-liked", "true"

    postComment: (e) ->
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      likes = Number activity.find(".like-count").html()
      data = activity.data()
      model = if data.collection is "user"
        Parse.User.current().activity.at(data.index)
      else Parse.App.activity.at(data.index)

      formData = activity.find("form.new-comment-form").serializeObject()

      return unless formData.comment and formData.comment.title

      # Use a pointer, to make sure we don't run into double-save issues.
      property = if model.get("property")
        __type: "Pointer"
        className: "Property"
        objectId: model.get("property").id
      else undefined

      network = if model.get("network")
        __type: "Pointer"
        className: "Network"
        objectId: model.get("network").id
      else undefined

      comment = new Comment
        title: formData.comment.title
        center: model.get "center"
        profile: Parse.User.current().get "profile"
        activity:
          __type: "Pointer"
          className: "Activity"
          objectId: model.id
        property: property
        network: network

      # Optimistic saving.
      _.each @listViews, (lv) =>
        listItem = lv.find("#activity-#{model.id}")
        if listItem.length > 0 
          @addOneComment comment, listItem[0]
          # return false to avoid checking the other column.
          false

      activity.find("input.comment-title").val("")

      # Count is incremented in Comment afterSave
      newCount = model.get("commentCount") + 1
      model.set "commentCount", newCount
      activity.find(".comment-count").html newCount

      comment.save().then (obj) -> , 
      (error) =>
        console.log error
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors.unknown, type: 'error'
        model.set "commentCount", newCount - 1
        activity.find(".comments > li:last-child").remove()
        activity.find(".comment-count").html newCount - 1

    addOneComment : (comment, listItem) =>

      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      listItem.$el.find("ul.list-comments").append JST["src/js/templates/comment/summary.jst"](vars)

      # Find and update the heights of the scroll view.
      heightChange = listItem.$el.outerHeight(true) - listItem.height

      # Item
      listItem.height += heightChange
      listItem.bottom += heightChange

      # Page
      listItem.parent.height += heightChange
      listItem.parent.bottom += heightChange
      listItem.parent.$el.height listItem.parent.height

      # ListView
      listItem.parent.parent.height += heightChange
      listItem.parent.parent.bottom += heightChange
      listItem.parent.parent.$el.height listItem.parent.parent.height

      # Update positions for everything after index.
      infinity.updateItemPosition listItem.parent.items, heightChange, listItem.index + 1
      infinity.updatePagePosition listItem.parent.parent.pages, heightChange, listItem.parent.index + 1
      
    addAllComments: (collection) =>

      visible = if collection instanceof CommentList
        collection.groupBy (c) => c.get("activity").id
      else 
        _.groupBy collection, (c) => c.get("activity").id

      for modelId in _.keys visible

        _.each @listViews, (lv) =>
          listItem = lv.find("#activity-#{modelId}")
          if listItem.length > 0
            for comment in visible[modelId]
              @addOneComment comment, listItem[0]
              # return false to avoid checking the other column.
            false

    # Map-specific
    # --------------

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


    # Modal 
    # @see profile:show and property:public
    # --------------------------------------------

    showModal : (e) =>
      e.preventDefault()
      @modal = true
      data = $(e.currentTarget).parent().data()
      # Keep track of where we are, for subsequent navigation.
      @index = data.index
      @collection = data.collection
      model = if @collection is "user"
        Parse.User.current().activity.at(@index)
      else Parse.App.activity.at(@index)
      @renderModalContent model
      $("#view-content-modal").modal(keyboard: false)

      # Add events.
      $(document).on "keydown", @controlModalIfOpen
      $('#view-content-modal').on 'click', '.caption a', @closeModal
      $('#view-content-modal').on 'click', '.left', @prevModal
      $('#view-content-modal').on 'click', '.right', @nextModal
      $('#view-content-modal').on 'hide.bs.modal', @hideModal
      $('#view-content-modal').on 'click', '.like-button', @likeOrLogin
      $('#view-content-modal').on 'click', '.likers', @getLikers
      $('#view-content-modal').on 'submit', 'form', @postComment

    controlModalIfOpen : (e) =>
      return unless @modal
      switch e.which 
        when 27 then $("#view-content-modal").modal('hide')
        when 37 then @prevModal()
        when 39 then @nextModal()

    closeModal : =>
      $("#view-content-modal").modal('hide')

    hideModal : =>
      return unless @modal
      @modal = false
      @detachModalEvents()

    detachModalEvents: ->
      $(document).off "keydown"
      $('#view-content-modal').off "hide click"
      # $('#view-content-modal .caption a').off 'click'
      # $('#view-content-modal .left').off 'click'
      # $('#view-content-modal .right').off 'click'

    nextModal : =>
      return unless @modal
      @index++
      model = if @collection is "user"
        if @index >= Parse.User.current().activity.length then @index = 0
        Parse.User.current().activity.at(@index)
      else
        if @index >= Parse.App.activity.length then @index = 0
        Parse.App.activity.at(@index)
      @renderModalContent model

    prevModal : =>
      return unless @modal
      @index--
      model = if @collection is "user"
        if @index < 0 then @index = Parse.User.current().activity.length - 1
        Parse.User.current().activity.at(@index)
      else
        if @index < 0 then @index = Parse.App.activity.length - 1
        Parse.App.activity.at(@index)
      @renderModalContent model

    renderModalContent : (model) =>

      # Add a building link if applicable.
      # Cache result
      property = if model.get("property") and not model.linkedToProperty() then model.get("property") else false

      vars = _.merge model.toJSON(), 
        url: model.url()
        profileUrl: model.profileUrl()
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        liked: model.liked()
        postImage: model.image("large")
        icon: model.icon()
        name: model.name()
        profilePic: model.profilePic("thumb")
        propertyLinked: if property then true else false
        propertyTitle: if property then property.get("title") else false
        propertyCover: if property then property.cover("tiny") else false
        propertyUrl: if property then property.publicUrl() else false
        current: Parse.User.current()
        i18nCommon: i18nCommon

      if Parse.User.current()
        vars.self = Parse.User.current().get("profile").name()
        vars.selfProfilePic = Parse.User.current().get("profile").cover("tiny")

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likeCount: 0
        commentCount: 0

      # Override default title.
      vars.title = model.title()

      $("#view-content-modal").html JST["src/js/templates/activity/modal.jst"](vars)

      # Comments
      @$comments = $("#view-content-modal .list-comments")
      @$comments.html ""
      model.prep "comments"
      if model.comments.length > 0
        visible = model.comments.select (c) => c.get("activity") and c.get("activity").id is model.id
        if visible.length > 0 then _.each visible, @renderOneModalComment
      else 
        model.comments.model = model
        @listenToOnce model.comments, "reset", @renderAllModalComments, model
        model.comments.fetch()

    renderAllModalComments : (collection) =>
      visible = collection.select (c) => c.get("activity") and c.get("activity").id is collection.model.id
      if visible.length > 0 then _.each visible, @renderOneModalComment

    renderOneModalComment : (comment) =>

      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      @$comments.append JST["src/js/templates/comment/summary.jst"](vars)