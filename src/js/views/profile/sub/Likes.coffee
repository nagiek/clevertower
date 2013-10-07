define [
  "jquery"
  "underscore"
  "backbone"
  "infinity"
  "collections/ActivityList"
  "views/activity/list"
  "views/activity/BaseIndex"
  "i18n!nls/property"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, infinity, ActivityList, ActivityView, BaseIndexActivityView, i18nProperty, i18nUser, i18nCommon) ->

  class ProfileLikesView extends BaseIndexActivityView
  
    el: "#likes"

    events:
      'click ul > li > a.content'           : 'getModelDataToShowInModal'
      # Activity events
      "click .like-button"                  : "likeOrLogin"
      "click .likers"                       : "showLikers"
      "submit form.new-comment-form"        : "getCommentDataToPost"
    
    initialize: (attrs) ->
      super

      @current = attrs.current
      @$list = @$("ul")

      @modal = false

    render: ->
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

      @$loading = @$("#activity .loading")

      # Start activity search.      
      @addAllActivity @model.likes
      @addAllComments @model.comments
      @search() unless @model.likes.length > @resultsPerPage * @page

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
      # @modalCollection = @model.likes.select (a) => a.get("property") and a.get("property").id is @model.id
      model = @model.likes.at data.index

      ids = _.map(@modalCollection, (a) -> a.id)
      @modalIndex = _.indexOf(ids, model.id)

      @showModal()

    getCommentDataToPost: (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()
      model = @model.likes.at(data.index)

      @postComment activity, data, model

    # Activity
    # ------
    search : =>

      @$loading.html "<img src='/img/misc/spinner.gif' class='spinner' alt='#{i18nCommon.verbs.loading}' />"
      @moreToDisplay = true

      # handleMapActivity
      Parse.Promise.when(
        @model.likes.query.skip(@resultsPerPage * (@page - 1)).limit(@resultsPerPage).find(),
        @model.comments.query.skip(@commentsPerPage * (@page - 1)).limit(@commentsPerPage).find()
      ).then (objs, comms) =>

        if objs
          if objs.length < @resultsPerPage then @trigger "view:exhausted"

          # Set the property, as we may have not included it for property-specific queries.
          if objs[0] and not objs[0].get "property"
            _.each objs, (o) => o.set "property", @model

          @model.likes.add objs

          # We may be getting non-related models at this point.
          @addAllActivity objs
        else 
          @trigger if @model.likes.length > 0 then "view:exhausted" else "view:empty"

        if comms 
          _.each comms, (c) => c.set "property", @model
          @model.comments.add comms

          @addAllComments comms
          # if objs.length < @resultsPerPage then @trigger "view:exhausted"
        # @refreshDisplay()

        @checkIfEnd() if @activityCount

      # Save the hassle of updatePaginiation on the first go-round.
      # We can infer whether we need it the second time around.
      if @page is 2 then @updatePaginiation()

    checkIfEnd : =>

      # Check if we have hit the end.
      if @model.likes.length >= @activityCount then @trigger "view:exhausted"

    # addOneActivity : (activity) =>
    #   view = new ActivityView(model: activity, onProfile: false)
    #   @$activity.append view.render().el

    updatePaginiation : =>
      countQuery = @model.likes.query
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

      visible = @modalCollection = if collection instanceof ActivityList
        collection.select (a) =>
          a.get("property") and a.get("property").id is @model.id
      else 
        _.select collection, (a) =>
          a.get("property") and a.get("property").id is @model.id

      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + i18nProperty.tenant_empty.activity + '</div>'

      

    # # Activity
    # # ---------
    # addOne : (a) =>
    #   view = new ActivityView
    #     model: a
    #     liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
    #     onProfile: true
    #   @$list.append view.render().el

    # addAll : =>
    #   @$list.html ""

    #   unless @model.likes.length is 0

    #     # Group by date.
    #     dates = @model.likes.groupBy (a) -> moment(a.createdAt).format("LL")
    #     _.each dates, (set, date) =>
    #       @$list.append "<li class='nav-header'>#{date}</li>"
    #       _.each set, @addOne
    #       @$list.append "<li class='divider clearfix'></li>"

    #   else 
    #     text = if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other @model.get("first_name") || @model.name()
    #     @$list.html '<li class="empty">' + text + '</li>'
    
    # render: ->      

    #   if @model.likes.length > 0 then @addAll() else @model.likes.fetch()
    #   @
      
    # # Activity
    # # ---------
    # addOne : (a) =>
    #   view = new ActivityView
    #     model: a
    #     liked: @current or (Parse.User.current() and Parse.User.current().get("profile").likes.contains a)
    #     currentProfile: @current
    #   @$list.append view.render().el

    # addAll : =>
    #   @$list.html ""

    #   unless @model.likes.length is 0
    #     @model.likes.each @addOne
    #   else 
    #     text = if @current then i18nUser.empty.likes.self else i18nUser.empty.likes.other @model.get("first_name") || @model.name()
    #     @$list.html '<li class="empty">' + text + '</li>'