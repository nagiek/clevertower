define [
  "jquery"
  "underscore"
  "backbone"
  'collections/ActivityList'
  "views/listing/Search"
  "views/post/New"
  "views/property/Prompt"
  "views/activity/summary"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'masonry'
  'jqueryui'
  "gmaps"
], ($, _, Parse, ActivityList, ListingSearchView, NewPostView, PromptPropertyView, ActivitySummaryView, i18nListing, i18nCommon) ->

  class ActivityIndexView extends Parse.View
  
    el: "#main"

    events:
      'click #filters > button'   : 'changeType'
      'click #displays > button'  : 'changeDisplay'
      'change #redo-search'       : 'changeSearchPrefs'
    
    initialize : (attrs) ->

      @location = attrs.location || "Montreal--QC--Canada"
      @locationAppend = if attrs.params.lat and attrs.params.lng then "?lat=#{attrs.params.lat}&lng=#{attrs.params.lng}" else ''
      @page = attrs.params.page || 1
      @center = new google.maps.LatLng attrs.params.lat, attrs.params.lng if attrs.params.lat and attrs.params.lng
      @display = 'small'

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        @getUserActivity()
        @userView = new NewPostView(map: @map).render()

      @listenTo Parse.App.search, "google:search", (data) =>
        @location = data.location
        @placesService.getDetails reference: data.reference, @googleSearch

      @on "model:viewDetails", @clear
      @on "dragend", @checkIfShouldSearch

      # Create a timer to buffer window re-draws.
      @time = null

      @redoSearch = true
      @mapId = "mapCanvas"

      @resultsPerPage = 20
      # The chunk is the start of the group of pages we are displaying
      @chunk = Math.floor(@page / @resultsPerPage) + 1
      # The chunkSize is the number of pages displayed in a group
      @chunkSize = 10

      # Activity that we find on the map.
      unless Parse.App.activity
        Parse.App.activity = new ActivityList([], {})
        Parse.App.activity.query
        .include("property")
        .containedIn("activity_type", ["new_photo", "new_listing", "new_post"])

      @listenTo Parse.App.activity, "reset", @addAll
      @listenTo Parse.App.activity, "add", @addOne

      if Parse.User.current() then @getUserActivity() else @render()

    refreshDisplay : ->
      Parse.App.activity.each (a) -> a.trigger "refresh"
      if Parse.User.current() and Parse.User.current().activity
        Parse.User.current().activity.each (a) -> a.trigger "refresh" 
      @$list.masonry 'reload'

    changeType: (e) ->
      e.preventDefault()
      
      btn = @$(e.currentTarget)
      filter = btn.data "filter"
      return if filter is @filter
      @filter = filter
      if @filter

        @specificSearchControls.clear() if @specificSearchControls
        # "Specific" filter
        Parse.App.activity.query.containedIn "activity_type", [@filter]

        switch @filter
          when "new_listing" then @specificSearchControls = new ListingSearchView(view: @).render()

        # Groom the incoming data.
        Parse.App.activity.remove Parse.App.activity.select((m) => @filter isnt m.get("activity_type"))

        # Remove the User activity, which is still showing.
        # handleUserActivity() will not do it, as it only removes activity not shown on the map.
        if Parse.User.current()

          userActivityToRemove = Parse.User.current().activity.select((a) => a.get("activity_type") isnt @filter)
          userActivityToRemove = userActivityToRemove.concat Parse.User.current().activity.select(@specificSearchControls.filter) if @specificSearchControls 
          if userActivityToRemove.length > 0
            _.each userActivityToRemove, (a) => a.trigger('remove') 
            @refreshDisplay()
          @handleUserActivity() 

        Parse.App.activity.query.notContainedIn("objectId", Parse.App.activity.map((l) -> l.id))
        .find()
        .then (objs) =>
          Parse.App.activity.add objs if objs
          Parse.User.current().activity.query.notContainedIn("objectId", Parse.User.current().activity.map((l) -> l.id)).find() if Parse.User.current()
        .then (objs) =>
          Parse.App.activity.add objs if Parse.User.current() and objs
          @refreshDisplay()

      else
        # "All" filter
        # Total reset

        if Parse.User.current()
          # Don't actually reset the collection, but fire the event to clear all the views.
          Parse.User.current().activity.trigger "reset"
          @handleUserActivity()

        Parse.App.activity.query.containedIn "activity_type", ["new_photo", "new_listing", "new_post"]
        Parse.App.activity.fetch()

    changeDisplay: (e) =>
      e.preventDefault()
      display = e.currentTarget.attributes["data-display"].value

      return if display is @display
      @display = display

      @trigger "view:changeDisplay", @display
      @$list.masonry 'reload'

    changeSearchPrefs : (e) =>
      if @redoSearch
        @redoSearch = false
      else 
        @redoSearch = true
        @performSearchWithinMap()

    getUserActivity : =>
      # Get the property from what we've already loaded.
      Parse.User.current().activity = new ActivityList [], {} unless Parse.User.current().activity
      if Parse.User.current().get("property")
        @center = @GPoint Parse.User.current().get("property").get("center") unless @center
        @radius = 15000

        # Activity list for *property*        
        Parse.User.current().activity.query.equalTo "property", Parse.User.current().get("property")
        @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity
        Parse.App.activity.query.notEqualTo "property", Parse.User.current().get("property")

        # Render immediately, as we already have the center & radius from the property
        @render()

      else if Parse.User.current().get("network")

        # Activity list for *network*
        unless Parse.User.current().activity
          Parse.User.current().activity.query.equalTo "network", Parse.User.current().get("network")
          @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity
          Parse.App.activity.query.notEqualTo "network", Parse.User.current().get("network")

        # Render asynchronously, while we wait for the property info to come in so we can determine our center & radius
        if Parse.User.current().get("network").properties.length is 0
          @listenToOnce Parse.User.current().get("network").properties, "reset", @getSetting
        else
          @getSetting()
      else
        @render()

    render: ->
      vars = 
        today: moment().format("L")
        i18nListing: i18nListing
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/activity/index.jst"](vars)
      
      @$('[rel=tooltip]').tooltip placement: 'bottom'

      @$list = @$(".content > ul")
      @$list.masonry
        selector : 'li'
        columnWidth: (containerWidth) -> containerWidth / 2

      @$pagination = @$(".content > .pagination ul")
      # Record our fixed block.
      @$block = @$('#map-container')
      @$block.original_position = @$block.offset()

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
              @center = new google.maps.LatLng 43.6481, -79.4042
              @radius = 15000
              @renderMap()
          , =>
            @center = new google.maps.LatLng 43.6481, -79.4042
            @radius = 15000
            @renderMap()
        else
          @center = new google.maps.LatLng 43.6481, -79.4042
          @radius = 15000
          @renderMap()

      # Track scrolling & resizing for map
      $(window).resize @resize
      $(document.documentElement).resize @resize
      $(window).scroll @tracker
      $(document.documentElement).scroll @tracker

      @

    renderMap : =>

      if @radius > 1000000 then zoom = 4
      else if @radius > 300000 then zoom = 5
      else if @radius > 150000 then zoom = 6
      else if @radius > 72500 then zoom = 8
      else if @radius > 35000 then zoom = 9
      else if @radius > 18800 then zoom = 10
      else if @radius > 9300 then zoom = 11
      else if @radius > 4600 then zoom = 12
      else zoom = 13
      # else if @radius > 23000 then zoom = 14
      # else if @radius > 9000 then zoom = 15
      # else zoom = 16

      @map = new google.maps.Map document.getElementById(@mapId), 
        zoom              : zoom
        center            : @center
        mapTypeId         : google.maps.MapTypeId.ROADMAP
        mapTypeControl    : false
        streetViewControl : false

      if Parse.User.current()
        Parse.User.current().activity.fetch() if Parse.User.current().activity
        @userView = new NewPostView(view: @).render()

        if Parse.User.current().get("property")
          Parse.User.current().get("property").marker = new google.maps.Marker
            position: @center
            map:      @map
            ZIndex:   1
            icon: 
              url: "/img/icon/pins-sprite.png"
              size: new google.maps.Size(25, 32, "px", "px")
              origin: new google.maps.Point(0, 0)
              anchor: null
              scaledSize: null
        else if Parse.User.current().get("network")
          Parse.User.current().get("network").properties.each (p) =>
            p.marker = new google.maps.Marker
              position: @GPoint p.get("center")
              map:      @map
              ZIndex:   1
              icon: 
                url: "/img/icon/pins-sprite.png"
                size: new google.maps.Size(25, 32, "px", "px")
                origin: new google.maps.Point(50, p.pos() * 32)
                anchor: null
                scaledSize: null

      @dragListener = google.maps.event.addListener @map, 'dragend', => @trigger "dragend"
      @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch
      google.maps.event.addListenerOnce @map, 'idle', @performSearchWithinMap

    initWithCenter : (place, status) =>
      @center = place.geometry.location if status is google.maps.places.PlacesServiceStatus.OK
      @radius = 15000
      @renderMap()

    googleSearch : (place, status) =>

      if status is google.maps.places.PlacesServiceStatus.OK

        oldBounds = @map.getBounds()
        @center = place.geometry.location
        @map.setCenter @center
        newBounds = @map.getBounds()

        # Dump the collection if we are going somewhere different.
        Parse.App.activity.reset() unless oldBounds.intersects newBounds

        @chunk = 1
        @page = 1

        @performSearchWithinMap()

    checkIfShouldSearch : =>
      if @redoSearch
        @chunk = 1
        @page = 1
        @performSearchWithinMap()
  
    performSearchWithinMap : =>
      center = @map.getCenter()
      @locationAppend = "?lat=#{center.lat()}&lng=#{center.lng()}"
      Parse.history.navigate "/search/#{@location}#{@locationAppend}"

      bounds = @map.getBounds()
      @sw = new Parse.GeoPoint(bounds.getSouthWest().lat(), bounds.getSouthWest().lng())
      @ne = new Parse.GeoPoint(bounds.getNorthEast().lat(), bounds.getNorthEast().lng())

      # Reset map
      Parse.App.activity.setBounds @sw, @ne
      Parse.App.activity.query.skip(0)

      @search()

    search: ->
      @handleUserActivity() if Parse.User.current() 
      @handleMapActivity()
      @updatePaginiation()

    handleUserActivity : ->
      # Check if activity is visible or not.
      if Parse.User.current().get("property") 
        p = Parse.User.current().get("property") 
        if @withinBounds p then @showPropertyActivity p else @hidePropertyActivity p
        @refreshDisplay()
      else if Parse.User.current().get("network")
        Parse.User.current().get("network").properties.each (p) => 
          if @withinBounds p.get("center") then @showPropertyActivity p else @hidePropertyActivity p
        @refreshDisplay()

    handleMapActivity : ->

      # Found Activity
      if Parse.App.activity.length is 0
        # Start from scratch
        Parse.App.activity.query.limit(@resultsPerPage)
        Parse.App.activity.fetch()
      else
        # Groom the incoming data.
        activitiesToRemove = Parse.App.activity.select (a) =>
          !@withinBounds(a.get("center")) or 
          (@specificSearchControls and !@specificSearchControls.filter(a))

        if activitiesToRemove.length > 0 or Parse.App.activity.length < @resultsPerPage
          
          # Find new things to replace
          replaceQuery = Parse.App.activity.query
          replaceQuery.notContainedIn("objectId", Parse.App.activity.map((l) -> l.id))

          # Determine our limit
          if activitiesToRemove.length > 0
            Parse.App.activity.remove(activitiesToRemove) 
            replaceQuery.limit(activitiesToRemove.length)
          else
            replaceQuery.limit(@resultsPerPage - Parse.App.activity.length)

          replaceQuery.find()
          .then (objs) =>
            if objs
              Parse.App.activity.add objs
              @refreshDisplay()

    addOne: (a) =>
      view = new ActivitySummaryView
        model: a
        view: @
      if a.createdAt is undefined then view.$el.addClass "fade in"
      @$list.append view.render().el

    addOnePropertyActivity: (a) => 
      view = new ActivitySummaryView
        model: a
        marker: a.get("property").marker
        pos: a.get("property").pos()
        view: @
        linkedToProperty: true
      if a.createdAt is undefined then view.className += " fade in" 
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.find(".loading").remove()
      @$list.find("> .general").remove()
      unless Parse.App.activity.length is 0
        @$('li.empty').remove() if @$('li.empty')
        Parse.App.activity.each @addOne
      else
        @$list.append '<li class="general empty">' + i18nListing.listings.empty.index + '</li>'
      @refreshDisplay()
    
    # Show activity where we have already loaded the property
    showPropertyActivity: (property) =>
      Parse.User.current().activity.chain()
        .filter (a) => 
          a.get("property").id is property.id and 
          (!@filter or @filter is a.get("activity_type")) and 
          (!@specificSearchControls or @specificSearchControls.filter(a))
        .each (a) =>
          # We need the property's position within the collection.
          a.set "property", property
          @addOnePropertyActivity a

    hidePropertyActivity: (property) =>
      Parse.User.current().activity.chain()
        .filter((a) -> a.get("property").id is property.id and 
          (!@filter or @filter isnt a.get("activity_type")) and 
          (!@specificSearchControls or !@specificSearchControls.filter(a)))
        .each (a) -> a.trigger('remove')

    # Update the pagination with appropriate count, pages and page numbers 
    updatePaginiation : =>
      countQuery = Parse.App.activity.query
      # Reset old filters
      countQuery.notContainedIn("objectId", [])
      # Limit of -1 means do not send a limit.
      countQuery.limit(-1).skip(0).count()
      .then (count) =>
        # remaining pages
        @pages = Math.ceil((count / @resultsPerPage))
        @renderPaginiation()
    
    renderPaginiation : (e) =>
      
      @$('.pagination > ul > li > a').off 'click'
      @$pagination.html ""

      pages = @pages - @chunk + 1

      if pages > @chunkSize then pages = @chunkSize; next = true

      if @chunk > 1 then @$pagination.append "<li><a href='#' class='prev' data-page='prev'>...</a></li>"

      url = "/search/#{@location}" 
      for page in [@chunk..@chunk + pages - 1] by 1
        if page > 1
          append = @locationAppend + (if @locationAppend.length > 0 then "&" else "?") + "page=#{page}"
        else 
          append = @locationAppend
        @$pagination.append "<li><a data-page='#{page}' href='#{url}#{append}'>#{page}</a></li>"
      if next then @$pagination.append "<li><a href='#' class='next' data-page='next'>...</a></li>"

      if @chunk <= @page and @page < @chunk + @chunkSize
        # @chunk > 1 means that prev chunks exist, and a prev button is displayed
        n = @page - @chunk + 1 + if @chunk > 1 then 1 else 0
        @$pagination.find(":nth-child(#{n})").addClass('active')

      @$('.pagination > ul > li > a').on 'click', @changePage


    # Change the page within the current pagination.
    changePage : (e) =>
      e.preventDefault()
      selected = e.currentTarget.attributes["data-page"].value

      if selected is 'next' or selected is 'prev'
        # Change the chunk
        @chunk = if selected is 'next' then @chunk + @chunkSize else @chunk - @chunkSize
        @renderPaginiation()
        
      else
        # Change the page within the chunk
        @page = selected
        @$pagination.find("li > .active").removeClass('active')

        n = Math.round(@page / @chunkSize) + if @chunk > 1 then 1 else 0
        @$pagination.find(":nth-child(#{n})").addClass('active')
        
        Parse.App.activity.query.skip(@resultsPerPage * (@page - 1))

        # Reset and get new
        Parse.App.activity.reset()
        @performSearchWithinMap()

    
    # Track positioning and visibility.
    tracker: =>

      # Track position relative to the viewport and set position.
      vOffset = (document.documentElement.scrollTop or document.body.scrollTop)
      
      # @@@K Hack
      # trigger = 58
      if vOffset > @$block.original_position.top
        @$block.addClass "float-block-fixed"
      else
        @$block.removeClass "float-block-fixed"
  
    # Track resizing.
    resize : =>
      
      # Ensure minimum time between adjustments.
      return if @time
      @time = setTimeout =>

        # Reset the block and calculate new position
        @$block.removeClass "float-block-fixed"
        @$block.original_position = @$block.offset()

        @tracker()

        # Reset timer
        @time = null
      , 250

    getSetting : =>
      Parse.User.current().get("network").properties.getSetting()
      @center = @GPoint Parse.User.current().get("network").properties.center
      @radius = Parse.User.current().get("network").properties.radius
      @render()

    GPoint : (GeoPoint) -> new google.maps.LatLng GeoPoint._latitude, GeoPoint._longitude

    # These break everything. 
    # undelegateEvents is called after init. No idea why.
    # undelegateEvents : =>
      
    #   Parse.App.activity.off "add"
    #   Parse.App.activity.off "reset"

    #   Parse.App.search.off "google:search"

    #   google.maps.event.removeListener @dragListener
    #   google.maps.event.removeListener @zoomListener
    #   super

    withinBounds : (center) ->

      lat = center._latitude
      lng = center._longitude

      # If it is not outside the box
      !(lat < @sw._latitude || 
             @ne._latitude < lat || 
             lng < @sw._longitude || 
             @ne._longitude < lng)
          




    clear : => 
      @stopListening()
      @undelegateEvents()
      delete this
