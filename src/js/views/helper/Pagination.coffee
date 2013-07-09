define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  'collections/ActivityList'
  "views/listing/Search"
  "views/activity/New"
  "views/activity/Summary"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'masonry'
  'jqueryui'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, ListingSearchView, NewActivityView, ActivityView, i18nListing, i18nCommon) ->

  class PaginationView extends Parse.View
  
    el: "#main"

    events:
      'click #filters > button'         : 'changeType'
      'click #displays > button'        : 'changeDisplay'
      'change #redo-search'             : 'changeSearchPrefs'
      'click .pagination > ul > li > a' : 'changePage'
      'click .thumbnails a.content'     : 'showModal'
      'hide #view-content-modal'        : 'hideModal'
      'click .modal .caption a'         : 'closeModal'
      'click .modal .left'              : 'prevModal'
      'click .modal .right'             : 'nextModal'
    
    initialize : (attrs) ->

      @page = attrs.params.page || 1
      @resultsPerPage = 20
      # The chunk is the start of the group of pages we are displaying
      @chunk = Math.floor(@page / @resultsPerPage) + 1
      # The chunkSize is the number of pages displayed in a group
      @chunkSize 


    render: ->

      @$pagination = @$(".content > .pagination ul")
      @


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
