define [
  "jquery"
  "underscore"
  "backbone"
  'collections/HomeList'
  "views/listing/feed"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/listing/index'
  'masonry'
  'jqueryui'
  "gmaps"
], ($, _, Parse, HomeList, FeedListingView, i18nListing, i18nCommon) ->

  class IndexListingView extends Parse.View
  
    el: ".content"

    events:
      'click .display' : 'changeDisplay'
    
    initialize : (attrs) ->

      @location = attrs.location || "Montreal--QC--Canada"
      @page = attrs.page || 1

      $('#redo-search').on "click", => 
        @redoSearch = if @redoSearch then false else true
        if @redoSearch then @performSearchWithinMap()

      @redoSearch = true
      @display = 'List'
      @mapId = "mapCanvas"
      @min = 0
      @max = 6000

      @resultsPerPage = 20
      # The chunk is the start of the group of pages we are displaying
      @chunk = Math.floor(@page / @resultsPerPage) + 1
      # The chunkSize is the number of pages displayed in a group
      @chunkSize = 10
      @firstRun = true

      Parse.App.listings = new HomeList [], min: @min, max: @max unless Parse.App.listings
      Parse.App.listings.on "add", @addOne
      Parse.App.listings.on "reset", @addAll
      
      @placesService = new google.maps.places.PlacesService(document.getElementById(@mapId))

      # Set the initial map location if we have one
      if Parse.App.search.lastReference
        @placesService.getDetails reference: Parse.App.search.lastReference, @initWithCenter
      else if Parse.User.current() and Parse.User.current().lastReference
        @placesService.getDetails reference: Parse.User.current().lastReference, @initWithCenter
      else if attrs.location
        new Parse.Query("Search").descending("createdAt").equalTo("location", attrs.location).first()
        .then (obj) => 
          @placesService.getDetails reference: obj.get("reference"), @initWithCenter
        , =>
          @center = new google.maps.LatLng 43.6481, -79.4042
          @render()
      else
        @center = new google.maps.LatLng 43.6481, -79.4042
        @render()
      
      Parse.App.search.on "google:search", (data) =>
        @location = data.location
        @placesService.getDetails reference: data.reference, @googleSearch

    render: ->
      vars = 
        i18nListing: i18nListing
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/listing/index.jst"](vars)
      
      @$list = @$("> ul")
      @$pagination = @$("> .pagination ul")

      $("#price-slider").slider
        values: [@min, @max]
        step: 10
        range: true 
        min: 0
        max: 6000
        slide: (event, ui) -> 
          selector = if ui.value is ui.values[0] then "#slider-min" else "#slider-max"
          $(selector).html ui.value
        stop: (event, ui) => 
          @min = ui.values[0]
          @max = ui.values[1]
          Parse.App.listings.query.greaterThanOrEqualTo("rent", @min).lessThanOrEqualTo("rent", @max)
          @performSearchWithinMap()

      @map = new google.maps.Map document.getElementById(@mapId), 
        zoom              : 12
        center            : @center
        mapTypeId         : google.maps.MapTypeId.ROADMAP
        mapTypeControl    : false
        streetViewControl : false

      @dragListener = google.maps.event.addListener @map, 'dragend', @checkIfShouldSearch
      @zoomListener = google.maps.event.addListener @map, 'zoom_changed', @checkIfShouldSearch
      google.maps.event.addListenerOnce @map, 'idle', @performSearchWithinMap


    initWithCenter : (place, status) =>
      @center = place.geometry.location if status is google.maps.places.PlacesServiceStatus.OK
      @render()

    googleSearch : (place, status) =>

      if status is google.maps.places.PlacesServiceStatus.OK

        oldBounds = @map.getBounds()
        @center = place.geometry.location
        @map.setCenter @center
        newBounds = @map.getBounds()

        # Dump the collection if we are going somewhere different.
        Parse.App.listings.reset() unless oldBounds.intersects newBounds

        @chunk = 1
        @page = 1

        @performSearchWithinMap()

    checkIfShouldSearch : =>
      if @redoSearch
        Parse.history.navigate "/search/#{@location}"
        @chunk = 1
        @page = 1
        @performSearchWithinMap()
  

    performSearchWithinMap : =>
      bounds = @map.getBounds()
      sw = new Parse.GeoPoint(bounds.getSouthWest().lat(), bounds.getSouthWest().lng())
      ne = new Parse.GeoPoint(bounds.getNorthEast().lat(), bounds.getNorthEast().lng())
      Parse.App.listings.query.withinGeoBox('center', sw, ne)
      Parse.App.listings.query.skip(0)

      if Parse.App.listings.length is 0
        # Start from scratch
        Parse.App.listings.query.limit(@resultsPerPage)
        Parse.App.listings.fetch()
      else
        # Groom the incoming data.
        listingsToRemove = []
        Parse.App.listings.each (l) => 
          lat = l.get('center')._latitude
          lng = l.get('center')._longitude
          rent = l.get('rent')

          # If it is outside the box
          if lat < sw._latitude || 
             ne._latitude < lat || 
             lng < sw._longitude || 
             ne._longitude < lng || 

             # Or if it does not fit the price targets
             rent < @min || 
             rent > @max
            listingsToRemove.push l

        if listingsToRemove.length > 0
          Parse.App.listings.remove(listingsToRemove) 
          # Find new things to replace
          replaceQuery = Parse.App.listings.query
          replaceQuery.notContainedIn("objectId", Parse.App.listings.map((l) -> l.id)).find()
          replaceQuery.limit(listingsToRemove.length)
          replaceQuery.find()
          .then (objs) =>
            Parse.App.listings.add objs
          .then =>
            @$list.masonry 'reload'
        else 
          unless Parse.App.listings.length is @resultsPerPage
            replaceQuery = Parse.App.listings.query
            replaceQuery.limit(@resultsPerPage - Parse.App.listings.length).notContainedIn("objectId", Parse.App.listings.map((l) -> l.id)).find()
            .then (objs) =>
              Parse.App.listings.add objs
            .then =>
              @$list.masonry 'reload'

      @updatePaginiation()

    changeDisplay: (e) =>
      e.preventDefault()
      @display = e.currentTarget.attributes["data-display"].value
      @trigger "view:changeDisplay", @display
      @$list.masonry 'reload'

    addOne: (l) =>
      view = new FeedListingView
        model: l
        view: @
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless Parse.App.listings.length is 0
        @$('li.empty').remove() if @$('li.empty')
        Parse.App.listings.each @addOne
      else
        @$list.html '<li class="empty">' + i18nListing.listings.empty.index + '</li>'
      
      # Init our masonry
      unless @firstRun
        # Reload it in case we have come here before
        @$list.masonry 'reload'
      else
        @$list.masonry
          selector : 'li'
          columnWidth: (containerWidth) -> containerWidth / 2
        @firstRun = false
      

    # Update the pagination with appropriate count, pages and page numbers 
    updatePaginiation : =>

      countQuery = Parse.App.listings.query
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
      for page in [@chunk..@chunk + pages - 1] by 1
        @$pagination.append "<li><a data-page='#{page}' href='/search/#{@location}#{unless page is 1 then '/page/' + page else ''}'>#{page}</a></li>"
      if next then @$pagination.append "<li><a href='#' class='next' data-page='next'>...</a></li>"

      if @chunk <= @page and @page < @chunk + @chunkSize
        # @chunk > 1 means that prev chunks exist, and a prev button is displayed
        n = @page - @chunk + 1 + if @chunk > 1 then 1 else 0
        @$pagination.find(":nth-child(#{n})").addClass('active')

      @$('.pagination > ul > li > a').on 'click', @changePage


    # Change the page within the current pagination.
    changePage : (e) =>
      
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
        
        Parse.App.listings.query.skip(@resultsPerPage * (@page - 1))

        # Reset and get new
        Parse.App.listings.fetch()


    # These break everything. 
    # undelegateEvents is called after init. No idea why.
    # undelegateEvents : =>
      
    #   Parse.App.listings.off "add"
    #   Parse.App.listings.off "reset"

    #   google.maps.event.removeListener @dragListener
    #   google.maps.event.removeListener @zoomListener

    #   super
