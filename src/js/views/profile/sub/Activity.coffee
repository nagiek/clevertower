define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "collections/ActivityList"
  "collections/CommentList"
  "views/helper/Alert"
  "views/activity/BaseIndex"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, infinity, ActivityList, CommentList, Alert, BaseIndexActivityView, i18nUser, i18nCommon) ->

  class ProfileActivityView extends BaseIndexActivityView
  
    el: "#activity"

    events:
      'click .thumbnails a.content'           : 'getModelDataToShowInModal'
      'click .thumbnails button.get-comments' : 'getActivityCommentsAndCollection' # 'showModal'
      # Activity events
      "click .like-button"                    : "likeOrLogin"
      "click .likers"                         : "showLikers"
      "submit form.new-comment-form"          : "getCommentDataToPost"
    
    initialize: (attrs) ->
      super

      @current = attrs.current
      @$list = @$("ul")

      # @listenTo @model.activity, "add", @addOneActivity
      # @listenTo @model.activity, "reset", @addAllActivity

      @modal = false

    clear: =>
      @undelegateEvents()
      @remove()
      delete this

    render: ->

      @listViews[0] = new infinity.ListView @$('.list-view'), 
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

      @$loading = @$(".loading")

      # Start activity search.      
      @addAllActivity @model.activity
      @addAllComments @model.comments
      @search() unless @model.activity.length > @resultsPerPage * @page

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
      @modalCollection = @findModelActivity @model.likes if @page > 1 or !@modalCollection or _.isEmpty @modalCollection
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
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'error'


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

          # Set the profile, as we may have not included it for profile-specific queries.
          if objs[0] and not objs[0].get "profile"
            _.each objs, (o) => o.set "profile", @model

          addedObjs = @model.activity.add objs

          # We may be getting non-related models at this point.
          console.log objs
          console.log addedObjs
          @addAllActivity addedObjs

          if objs.length < @resultsPerPage then @trigger "view:exhausted"
        else 
          @trigger if @model.activity.length > 0 then "view:exhausted" else "view:empty"

        if comms 
          _.each comms, (c) => c.set "profile", @model
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

    # addOneActivity : (activity) =>
    #   view = new ActivityView(model: activity, onProfile: false)
    #   @$activity.append view.render().el

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

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

    addAllActivity: (collection, filter) =>

      visible = @findModelActivity collection

      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(@model.name()) + '</div>'

    findModelActivity: (collection) =>
      if collection instanceof ActivityList
        collection.select (a) =>
          a.get("profile") and a.get("profile").id is @model.id
      else 
        _.select collection, (a) =>
          a.get("profile") and a.get("profile").id is @model.id

    findModelComments: (collection) =>
      if collection instanceof CommentList
        collection.select (c) =>
          c.get("profile") and c.get("profile").id is @model.id
      else 
        _.select collection, (c) =>
          c.get("profile") and c.get("profile").id is @model.id

      

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

    #   unless @model.activity.length is 0

    #     # Group by date.
    #     dates = @model.activity.groupBy (a) -> moment(a.createdAt).format("LL")
    #     _.each dates, (set, date) =>
    #       @$list.append "<li class='nav-header'>#{date}</li>"
    #       _.each set, @addOne
    #       @$list.append "<li class='divider clearfix'></li>"

    #   else 
    #     text = if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other @model.get("first_name") || @model.name()
    #     @$list.html '<li class="empty">' + text + '</li>'