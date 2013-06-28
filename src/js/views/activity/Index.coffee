define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/ActivityList'
  "views/listing/Search"
  "views/post/New"
  "views/activity/summary"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'masonry'
  'jqueryui'
  "gmaps"
], ($, _, Parse, moment, ActivityList, ListingSearchView, NewPostView, ActivitySummaryView, i18nListing, i18nCommon) ->

  class ActivityIndexView extends Parse.View
  
    el: "#main"

    events:
      'click #filters > button'         : 'changeType'
      'click #displays > button'        : 'changeDisplay'
      'change #redo-search'             : 'changeSearchPrefs'
      'click .pagination > ul > li > a' : 'changePage'
      'click .thumbnails > li > a'      : 'showModal'
      'hide #view-content-modal'        : 'hideModal'
      'click .modal .caption a'         : 'closeModal'
      'click .modal .left'              : 'prevModal'
      'click .modal .right'             : 'nextModal'
    
    initialize : (attrs) ->
      @location = attrs.location || ""
      @locationAppend = if attrs.params.lat and attrs.params.lng then "?lat=#{attrs.params.lat}&lng=#{attrs.params.lng}" else ''
      @page = attrs.params.page || 1
      @center = new google.maps.LatLng attrs.params.lat, attrs.params.lng if attrs.params.lat and attrs.params.lng
      @display = 'small'

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        @getUserActivity()
        @userView = new NewPostView(view: @).render()
        @listenTo @userView, "view:resize", @bindMapPosition

      @listenTo Parse.App.search, "google:search", (data) =>
        @location = data.location
        @placesService.getDetails reference: data.reference, @googleSearch

      @on "model:view", @showModal
      @on "dragend", @checkIfShouldSearch
      @on "view:change", @clear

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

      @getUserActivity() if Parse.User.current()
      @render()

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

        appQuery = Parse.App.activity.query
        .notContainedIn("objectId", Parse.App.activity.map((l) -> l.id))
        .find()

        # Remove the User activity, which is still showing.
        # handleUserActivity() will not do it, as it only removes activity not shown on the map.
        if Parse.User.current()

          userActivityToRemove = Parse.User.current().activity.select((a) => a.get("activity_type") isnt @filter)
          userActivityToRemove = userActivityToRemove.concat Parse.User.current().activity.select(@specificSearchControls.filter) if @specificSearchControls 
          if userActivityToRemove.length > 0
            _.each userActivityToRemove, (a) => a.trigger('remove') 
          @handleUserActivity() 

          userQuery = Parse.User.current().activity.query
          .notContainedIn("objectId", Parse.User.current().activity.map((l) -> l.id))
          .find() 
        else 
          userQuery = undefined

        Parse.Promise.when(appQuery, userQuery)
        .then (objs, userObjs) =>
          Parse.App.activity.add objs if objs
          Parse.User.current().activity.add userObjs if Parse.User.current() and userObjs
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
      @$("ul.thumbnails").removeClass(@display).addClass(display)
      @display = display

      @trigger "view:changeDisplay", @display
      @$list.masonry 'reload'

    changeSearchPrefs : (e) =>
      if @redoSearch
        @redoSearch = false
      else 
        @redoSearch = true
        @search()

    getUserActivity : =>
      # Get the property from what we've already loaded.
      Parse.User.current().activity = new ActivityList [], {} unless Parse.User.current().activity
      
      if Parse.User.current().get("property")
        # Activity list for *property*        
        Parse.User.current().activity.query.equalTo "property", Parse.User.current().get("property")
        @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity
        Parse.App.activity.query.notEqualTo "property", Parse.User.current().get("property")

        # Visibility counter
        Parse.User.current().get("property").shown = false

      else if Parse.User.current().get("network")

        # Activity list for *network*
        Parse.User.current().activity.query.equalTo "network", Parse.User.current().get("network")
        @listenTo Parse.User.current().activity, 'add', @addOnePropertyActivity
        Parse.App.activity.query.notEqualTo "network", Parse.User.current().get("network")

        # Visibility counter
        Parse.User.current().get("network").properties.each (p) -> p.shown = false

    getPersonalizedMapCenter : =>
      if Parse.User.current()
        if Parse.User.current().get("property")
          @center = Parse.User.current().get("property").GPoint()
          @radius = 50000

        else if Parse.User.current().get("network")
          Parse.User.current().get("network").properties.getSetting()
          @center = @GPoint Parse.User.current().get("network").properties.center
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
      
      @$('[rel=tooltip]').tooltip placement: 'bottom'

      @$list = @$(".content > ul")
      @$list.masonry
        selector : 'li'
        columnWidth: (containerWidth) -> containerWidth / 2

      @$pagination = @$(".content > .pagination ul")
      # Record our fixed block.
      @$block = @$('#map-container')
      @bindMapPosition()

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
      $(window).scroll @tracker
      $(document.documentElement).scroll @tracker

      @

    renderMap : =>

      if @radius
        if @radius > 1000000 then zoom = 4
        else if @radius > 300000 then zoom = 5
        else if @radius > 500000 then zoom = 6
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
        Parse.User.current().activity.fetch() if Parse.User.current().activity

        if Parse.User.current().get("property")
          Parse.User.current().get("property").marker = new google.maps.Marker
            position: Parse.User.current().get("property").GPoint()
            map:      @map
            ZIndex:   1
            icon: 
              url: "/img/icon/pins-sprite.png"
              size: new google.maps.Size(25, 32, "px", "px")
              origin: new google.maps.Point(50, 0)
              anchor: null
              scaledSize: null
        else if Parse.User.current().get("network")
          Parse.User.current().get("network").properties.each (p) =>
            p.marker = new google.maps.Marker
              position: p.GPoint()
              map:      @map
              ZIndex:   1
              icon: 
                url: "/img/icon/pins-sprite.png"
                size: new google.maps.Size(25, 32, "px", "px")
                origin: new google.maps.Point(50, p.pos() * 32)
                anchor: null
                scaledSize: null
                
        @userView = new NewPostView(view: @).render()
        @listenTo @userView, "view:resize", @bindMapPosition

      @dragListener = google.maps.event.addListener @map, 'dragend', => @trigger "dragend"
      @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch

      # Search once the map is ready.
      google.maps.event.addListenerOnce @map, 'idle', @performSearchWithinMap

    initWithCenter : (place, status) =>
      @center = place.geometry.location if status is google.maps.places.PlacesServiceStatus.OK
      @radius = 50000
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

        @search()

    checkIfShouldSearch : =>
      if @redoSearch
        @chunk = 1
        @page = 1
        @search()
  
    search : =>
      center = @map.getCenter()
      @locationAppend = "?lat=#{center.lat()}&lng=#{center.lng()}"
      Parse.history.navigate "/search/#{@location}#{@locationAppend}"

      @performSearchWithinMap()

    performSearchWithinMap: =>
      bounds = @map.getBounds()
      @sw = new Parse.GeoPoint(bounds.getSouthWest().lat(), bounds.getSouthWest().lng())
      @ne = new Parse.GeoPoint(bounds.getNorthEast().lat(), bounds.getNorthEast().lng())

      # Reset map
      Parse.App.activity.setBounds @sw, @ne
      Parse.App.activity.query.skip(0)

      @$list.find('> li.empty').remove()
      # @$list.remove('> li.empty')

      @handleUserActivity() if Parse.User.current()
      @handleMapActivity()
      @updatePaginiation()

    handleUserActivity : ->
      # Check if activity is visible or not.
      if Parse.User.current().get("property") 
        p = Parse.User.current().get("property") 
        if @withinBounds p.get("center") then @showPropertyActivity p else @hidePropertyActivity p
      else if Parse.User.current().get("network")
        Parse.User.current().get("network").properties.each (p) => 
          if @withinBounds p.get("center") then @showPropertyActivity p else @hidePropertyActivity p

    handleMapActivity : ->

      # Found Activity
      if Parse.App.activity.length is 0
        # Start from scratch
        Parse.App.activity.query.limit(@resultsPerPage)
        replaceQuery = Parse.App.activity.query
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
        Parse.App.activity.add objs if objs
        @refreshDisplay()
          

    addOne: (a) =>
      view = new ActivitySummaryView
        model: a
        view: @
      if a.createdAt is undefined then view.$el.addClass "fade in"
      @$list.prepend view.render().el

    addOnePropertyActivity: (a) => 
      view = new ActivitySummaryView
        model: a
        marker: a.get("property").marker
        pos: a.get("property").pos()
        view: @
        linkedToProperty: true
      view.className += " fade in" unless a.createdAt
      @$list.prepend view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      if Parse.App.activity.length > 0
        Parse.App.activity.each @addOne
    
    # Show activity where we have already loaded the property
    showPropertyActivity: (property) =>
      Parse.User.current().activity.chain()
        .filter (a) => 
          !property.shown and
          a.get("property").id is property.id and 
          (!@filter or @filter is a.get("activity_type")) and 
          (!@specificSearchControls or @specificSearchControls.filter(a)) 
        .each (a) =>
          property.shown = true
          # We need the property's position within the collection.
          a.set "property", property
          @addOnePropertyActivity a

    hidePropertyActivity: (property) =>
      Parse.User.current().activity.chain()
        .filter((a) ->
          property.shown is true and 
          a.get("property").id is property.id and 
          (!@filter or @filter isnt a.get("activity_type")) and 
          (!@specificSearchControls or !@specificSearchControls.filter(a)))
        .each (a) ->
          property.shown = false
          a.trigger('remove')

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

          properties = Parse.User.current().get("network").properties.map (p) -> p.shown is true
          userCountQuery.containedIn "property", properties
          userCounting = userCountQuery.count()

      else 
        userCounting = undefined
      
      Parse.Promise
      .when(counting, userCounting)
      .then (count, userCount) =>
        # remaining pages
        userCount = 0 unless userCount
        @pages = Math.ceil((count + userCount)/ @resultsPerPage)
        @$pagination.html ""

        if count + userCount is 0
          @$list.prepend '<li class="general empty">' + i18nListing.listings.empty.index + '</li>'
        else 
          @renderPaginiation()
          
    
    renderPaginiation : (e) =>

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
        @search()

    bindMapPosition: =>
      @$block.original_position = @$block.offset()

    
    # Track positioning and visibility.
    tracker: =>

      # Track position relative to the viewport and set position.
      vOffset = (document.documentElement.scrollTop or document.body.scrollTop)
      
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
        @bindMapPosition()

        @tracker()

        # Reset timer
        @time = null
      , 250

    GPoint : (GeoPoint) -> new google.maps.LatLng GeoPoint._latitude, GeoPoint._longitude

    # These break everything. 
    # undelegateEvents is called after init. No idea why.
    # undelegateEvents : =>
    #   @off "model:viewDetails"
    #   @off "dragend"
    #   google.maps.event.removeListener @dragListener
    #   google.maps.event.removeListener @zoomListener
    #   super

    withinBounds : (center) ->

      lat = center._latitude
      lng = center._longitude

      # Determine if it is within the box.
      @sw._latitude < lat and
        lat < @ne._latitude and 
        @sw._longitude < lng and 
        lng < @ne._longitude

    showModal : (e) =>
      @modal = true
      data = $(e.currentTarget).data()
      @index = data.index
      @collection = data.collection
      model = if @collection is "user"
        Parse.User.current().activity.at(@index)
      else Parse.App.activity.at(@index)
      @renderModalContent(model)
      @$("#view-content-modal").modal(keyboard: false)
      $(document).on "keyup", @controlModalIfOpen

    controlModalIfOpen : (e) =>
      return unless @modal
      switch e.which 
        when 27 then @$("#view-content-modal").modal('hide')
        when 37 then @prevModal()
        when 39 then @nextModal()

    closeModal : =>
      @$("#view-content-modal").modal('hide')

    hideModal : =>
      console.log 'hide'
      return unless @modal
      @modal = false
      $(document).off "keyup"

    nextModal : =>
      return unless @modal
      @index++
      model = if @collection is "user"
        if @index > Parse.User.current().activity.length then @index = 0
        Parse.User.current().activity.at(@index)
      else
        if @index >= Parse.App.activity.length then @index = 0
        Parse.App.activity.at(@index)
      @renderModalContent(model)

    prevModal : =>
      return unless @modal
      @index--
      model = if @collection is "user"
        if @index < 0 then @index = Parse.User.current().activity.length - 1
        Parse.User.current().activity.at(@index)
      else
        if @index < 0 then @index = Parse.App.activity.length - 1
        Parse.App.activity.at(@index)
      @renderModalContent(model)

    clear: =>
      $(window).off "resize scroll"
      $(document.documentElement).off "resize scroll"
      @undelegateEvents()
      @stopListening()
      delete this

    renderModalContent : (model) ->
      title = model.get("title")
      if model.get('profile') 
        profilePic = model.get('profile').cover("thumb")
        name = model.get('profile').name()
        url = model.get('profile').url()
      else 
        profilePic = model.get('property').cover("thumb")
        name = model.get('property').get("title")
        url = model.get('property').publicUrl()
      profileInfo = """
              <header class="clearfix">
                <div class="photo photo-thumbnail stay-left">
                  <a href="#{url}"><img src="#{profilePic}" alt="Profile" class="img-rounded profile-picture"></a>
                </div>
                <div class="photo-float thumbnail-float">
                  <p><a href="#{url}"><strong>#{name}</strong></a></p>
                  <p><small>#{moment(model.createdAt).fromNow()}</small></p>
                </div>
              </header>
               """
      switch model.get("activity_type")
        when "new_listing"
          cover = model.get('property').cover("span6")
          content = """
                    <div class="row-fluid">
                      <div class="photo-container span8">
                        <div class="photo">
                          <img src="#{model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                        </div>
                        <a class="left modal-control-area" href="#">
                          <span class="modal-control">&lsaquo;</span>
                        </a>
                        <a class="right modal-control-area" href="#">
                          <span class="modal-control">&rsaquo;</span>
                        </a>
                      </div>
                      <div class="caption span4">
                        <div class="clearfix">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        </div>
                        #{profileInfo}
                        <strong>#{title}</strong>
                        <div class="rent stay-right">#{rent}</div>
                      </div>
                    </div>
                    """
        when "new_post"

          if model.get "image"
            content = """
                      <div class="row-fluid">
                        <div class="photo-container span8">
                          <div class="photo">
                            <img src="#{model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                          </div>
                          <a class="left modal-control-area" href="#">
                            <span class="modal-control">&lsaquo;</span>
                          </a>
                          <a class="right modal-control-area" href="#">
                            <span class="modal-control">&rsaquo;</span>
                          </a>
                        </div>
                        <div class="caption span4">
                          <div class="clearfix">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          </div>
                          #{profileInfo}
                          <p class="desc">#{title}</p>
                        </div>
                      </div>
                      """
          else
            content = """
                      <div class="row-fluid">
                        <div class="position-relative span8">
                          <blockquote>
                            #{title}
                          </blockquote>
                          <a class="left modal-control-area" href="#">
                            <span class="modal-control">&lsaquo;</span>
                          </a>
                          <a class="right modal-control-area" href="#">
                            <span class="modal-control">&rsaquo;</span>
                          </a>
                        </div>
                        <div class="caption span4">
                          <div class="clearfix">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          </div>
                          #{profileInfo}
                        </div>
                      </div>
                      """
        when "new_photo"
          icon = 'photo'
          content = """
                    <div class="row-fluid">
                      <div class="photo-container span8">
                        <div class="photo">
                          <img src="#{model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                        </div>
                        <a class="left modal-control-area" href="#">
                          <span class="modal-control">&lsaquo;</span>
                        </a>
                        <a class="right modal-control-area" href="#">
                          <span class="modal-control">&rsaquo;</span>
                        </a>
                      </div>
                      <div class="caption span6">
                        <div class="clearfix">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        </div>
                        <strong>#{title}</strong>
                        #{footer}
                      </div>
                    </div>
                    """

      # content += """
      #             <a class="modal-control left" href="#">&lsaquo;</a>
      #             <a class="modal-control right" href="#">&rsaquo;</a>
      #            """

      @$("#view-content-modal").html content
