define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "collections/ActivityList"
  "views/activity/list"
  "views/activity/BaseIndex"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, infinity, ActivityList, ActivityView, BaseIndexActivityView, i18nUser, i18nCommon) ->

  class ProfileLikesView extends BaseIndexActivityView
  
    el: "#likes"

    events:
      'click .thumbnails a.content'             : 'getModelDataToShowInModal'
      'click .thumbnails button.get-comments'   : 'getActivityCommentsAndCollection'
      'click .thumbnails a.apply'               : 'applyToListingFromActivity'
      # Activity events
      "click .like-button"                    : "likeOrLoginFromActivity"
      "click .likers"                         : "getLikersFromActivity"
      "submit form.new-comment-form"          : "getCommentDataToPost"
    
    initialize: (attrs) ->

      super

      @current = attrs.current
      @$list = @$("ul")

      @listenTo @model.likes, "add", @addOneActivity
      @listenTo @model.likes, "reset", @addAllActivity

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
            if data.subject then item.$el.find("footer img.profile-pic").prop 'src', data.subject
            item.loaded = true

      @$loading = @$(".loading")

      # Start activity search.
      @addAllActivity @model.likes if @model.likes.length > 0
      @addAllComments @model.comments if @model.comments.length > 0

      # Assume we have been here before if @model.activity.length > 0
      @search() unless @model.likes.length > 0

      @

    # BaseIndex Linkers
    # ------------------

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parents(".activity").data()

      # Keep track of where we are, for subsequent navigation.
      # Convert the index to an array and find the "new" index.
       
      # Could use the cached results from addAllActivity unless we've loaded new data
      @modalCollection = @findModelActivity @model.likes
      @modalCommentCollection = @findModelComments @model.comments

      model = @model.likes.at data.index

      ids = _.map(@modalCollection, (a) -> a.id)
      @modalIndex = _.indexOf(ids, model.id)

      @showModal()

    getCommentDataToPost: (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.parents(".activity")
      data = activity.data()
      model = @model.likes.at(data.index)

      @postComment activity, model

    getActivityCommentsAndCollection : (e) =>
      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.parents(".activity")
      data = activity.data()
      model = @model.likes.at(data.index)
      comments = @model.comments

      button.button("loading")

      @getActivityComments(model, comments).then (newComms) =>
        addedComms = comments.add newComms
        @addAllComments addedComms
        button.button("reset")
      , =>
        button.button("reset")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'danger'
    
    addCommentToCollection : (comment) => @model.comments.add comment 
    

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

          # Set the profile, as we may have not included it for profile-specific queries.
          if objs[0] and not objs[0].get "subject"
            _.each objs, (o) => o.set "subject", @model

          addedObjs = @model.likes.add objs

          # We may be getting non-related models at this point.
          # @addAllActivity addedObjs

          if objs.length < @resultsPerPage then @trigger "view:exhausted"
        else 
          @trigger if @model.likes.length > 0 then "view:exhausted" else "view:empty"

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
      if @model.likes.length >= @activityCount then @trigger "view:exhausted"

    # addOneActivity : (activity) =>
    #   view = new ActivityView(model: activity, onProfile: false)
    #   @$activity.append view.render().el


    likeOrLoginFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.parents(".activity")
      data = activity.data()
      model = @model.likes.at(data.index)

      if Parse.User.current()
        @like model, activity, button, data, false
      else
        $("#signup-modal").modal()

    getLikersFromActivity: (e) =>
      e.preventDefault()
      button = @$(e.currentTarget)
      activity = button.parents(".activity")
      data = activity.data()
      model = @model.likes.at(data.index)

      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikersModal
      model.likers.fetch()

    applyToListingFromActivity: (e) =>
      e.preventDefault()
      if Parse.User.current()
        button = @$(e.currentTarget)
        activity = button.parents(".activity")
        data = activity.data()
        model = @model.likes.at(data.index)
        @applyToListing model
      else
        $('#login-modal').modal()

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.likes.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    checkIfFollowing: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsFollowing(activity) if model.subject().followedByUser()

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

      visible = @findModelActivity collection

      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(@model.name()) + '</div>'

    findModelActivity: (collection) =>
      if collection instanceof ActivityList
        collection.select (a) =>
          a.get("subject") and a.get("subject").id is @model.id
      else 
        _.select collection, (a) =>
          a.get("subject") and a.get("subject").id is @model.id

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