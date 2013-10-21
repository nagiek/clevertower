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
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/activity/index'
  'templates/activity/summary'
  'templates/activity/modal'
  'templates/comment/summary'
  # 'masonry'
  # 'jqueryui'
  "gmaps"
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Comment, ListingSearchView, NewActivityView, i18nListing, i18nCommon) ->

  class BaseActivityIndexView extends Parse.View
  
    el: "#main"

    events:
      'click .thumbnails a.content'             : 'getModelDataToShowInModal' # 'showModal'
      'click .thumbnails a.get-comments'        : 'getActivityCommentsAndCollection' # 'showModal'
      # Activity events
      "click .like-button"                      : "likeOrLogin"
      "click .likers"                           : "getLikers"
      "submit form.new-comment-form"            : 'getCommentDataToPost' # "postComment"
    
    initialize : (attrs) =>

      @page = attrs.params.page || 1
      @listViews = []
      @updateScheduled = false
      @moreToDisplay = true

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        # Check for likes.
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkForLikes

        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()

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

      @on "model:view", @showModal
      @on "view:change", @clear

      @on "view:exhausted", =>
        @moreToDisplay = false
        @$loading.html i18nCommon.activity.exhausted

      @on "view:empty", =>
        @moreToDisplay = false
        @$loading.html i18nListing.listings.empty.index

      @resultsPerPage = 20
      @commentsPerPage = 20
      # The chunkSize is the number of pages displayed in a group
      @chunkSize = 10
      # The chunk is the start of the group of pages we are displaying
      @chunk = Math.floor(@page / @resultsPerPage) + 1

      if Parse.User.current()
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkForLikes

        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()

    checkForLikes: ->
      Parse.User.current().get("profile").likes.each (l) =>
        _.each @listViews, (lv) =>
          activity = lv.find("> div > .activity-#{l.id}")
          if activity.length > 0
            @markAsLiked activity[0].$el
            # return false to avoid checking the other column.
            false

    redoSearch : =>

      # @chunk = 1
      @page = 1

      @resetListViews()
      @search()

    resetListViews: ->

      # Clean up old stuff
      _.each @listViews, (lv) -> lv.reset()

    filterCollections: ->
      # "Specific" filter
      Parse.App.activity.query.containedIn "activity_type", [@filter]
      Parse.User.current().activity.query.containedIn "activity_type", [@filter] if Parse.User.current()

      switch @filter
        when "new_listing" then @specificSearchControls = new ListingSearchView(view: @).render()

    resetFilters: ->
      Parse.App.activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"]
      Parse.User.current().activity.query.containedIn "activity_type", ["new_listing", "new_post", "new_property"] if Parse.User.current()

    # Adding from Collections
    # -----------------------

    renderTemplate: (model, liked, linked) =>

      # Create new element with extra details for infinity.js
      if linked
        collection = "user"
        propertyId = model.get("property").id
        propertyIndex = model.get("property").pos()
      else
        collection = "external"
        propertyId = false
        propertyIndex = false

      # Possible for the same activity to be on the page twice (in two different tabs)
      $el = $ """
      <div class="thumbnail clearfix activity activity-#{model.id} fade in"
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
        linkedToProperty: linked
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        postImage: model.image("large") # Keep this in for template logic.
        profileUrl: model.profileUrl()
        liked: liked
        icon: model.icon()
        name: model.name()
        current: Parse.User.current()
        i18nCommon: i18nCommon
        pos: if @onMap then (if linked then propertyIndex else model.pos()) % 20 else false # This will be incremented in the template.


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
        item = new infinity.ListItem @renderTemplate(a, false, true)
        item.marker = a.get("property").marker
        a.get("property").marker.items.push item
        @listViews[@shortestColumnIndex()].prepend item
      else
        # view = new ActivityView
        #   model: a
        #   view: @
        #   liked: false
        # # @listViews[@shortestColumnIndex()].prepend new infinity.ListItem view.render().$el
        @listViews[@shortestColumnIndex()].prepend @renderTemplate(a, false, false)

    addOneActivity: (a) =>
      # view = new ActivityView
      #   model: a
      #   view: @
      #   liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
      # @listViews[@shortestColumnIndex()].append view.render().$el
      @listViews[@shortestColumnIndex()].append @renderTemplate(a, a.liked(), false)
      # @$list.append view.render().el

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

    endOfDocument: =>
      viewportBottom = $(window).scrollTop() + $(window).height()
      @$loading.offset().top <= viewportBottom

    loadTracker: =>
      if(!@updateScheduled and @moreToDisplay)
        setTimeout =>
          if @endOfDocument() then @nextPage()
          @updateScheduled = false
        , 2000
        @updateScheduled = true


    # Change the page within the current pagination.
    nextPage : =>
      @page += 1
      @search()

    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this


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

    getLikers: (e) =>
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

    # Used just for display, not the action.
    markAsLiked: (activity) =>
      activity.find(".likers").addClass "active"
      activity.find(".like-button").text i18nCommon.adjectives.liked
      activity.data "liked", true
      # activity.attr "data-liked", "true"


    # Comments
    # --------

    postComment: (activity, model) =>

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
        listItem = lv.find("> div > .activity-#{model.id}")
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
      
    addAllComments : (collection) =>

      visible = if collection instanceof CommentList
        collection.groupBy (c) => c.get("activity").id
      else 
        _.groupBy collection, (c) => c.get("activity").id

      for modelId in _.keys visible

        _.each @listViews, (lv) =>
          listItem = lv.find("> div > .activity-#{modelId}")
          if listItem.length > 0

            # Decrease the "comment remaining" count
            remaining = listItem[0].$el.find(".remaining-comments").html()
            remaining = remaining - visible[modelId].length
            if remaining > 0 then listItem[0].$el.find(".remaining-comments").html(remaining)
            else listItem[0].$el.find(".additional-comments").addClass("hide")

            # Add comments
            for comment in visible[modelId]
              @addOneComment comment, listItem[0]
              # return false to avoid checking the other column.
            false

    getActivityComments : (model, existingComments) ->
      excludedComments = existingComments
        .chain()
        .select((c) -> c.get("activity").id is model.id)
        .map((c) -> c.id)
        .value()
      new Parse.Query("Comment")
        .equalTo("activity", model)
        .notContainedIn("objectId", excludedComments)
        .include("profile")
        .find()



    # Modal 
    # @see profile:show and property:public
    # --------------------------------------------

    undelegateEvents : =>
      super
      @detachModalEvents() if @modal

    showModal : =>

      @renderModalContent()
      $("#view-content-modal").modal(keyboard: false)

      # Add events.
      $(document).on "keydown", @controlModalIfOpen
      $('#view-content-modal').on 'click', 'ul.list-comments a', @closeModal
      $('#view-content-modal').on 'click', 'a.profile-link', @closeModal
      $('#view-content-modal').on 'click', 'a.get-comments', @getModalComments
      $('#view-content-modal').on 'click', '.left', @prevModal
      $('#view-content-modal').on 'click', '.right', @nextModal
      $('#view-content-modal').on 'hide.bs.modal', @hideModal
      $('#view-content-modal').on 'click', '.like-button', @likeOrLogin
      $('#view-content-modal').on 'click', '.likers', @getModalLikers
      $('#view-content-modal').on 'submit', 'form', @postModalComment

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
      @modalIndex++
      if @modalIndex >= @modalCollection.length then @modalIndex = 0

      @renderModalContent()

    prevModal : =>
      return unless @modal
      @modalIndex--
      if @modalIndex < 0 then @modalIndex = @modalCollection.length - 1

      @renderModalContent()

    renderModalContent : =>

      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]

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
      @$modalComments = $("#view-content-modal .list-comments")
      @$modalComments.html ""

      if model.get("commentCount") > 0
        visible = if @modalCommentCollection instanceof CommentList
          @modalCommentCollection.select (c) => c.get("activity") and c.get("activity").id is model.id
        else 
          _.select @modalCommentCollection, (c) => c.get("activity") and c.get("activity").id is model.id
        @renderAllModalComments visible

    renderAllModalComments : (visible) =>

      if visible.length > 0

        # Decrease the "comment remaining" count
        remaining = $("#view-content-modal .remaining-comments").html()
        remaining = remaining - visible.length
        if remaining > 0 then $("#view-content-modal .remaining-comments").html(remaining)
        else $("#view-content-modal .additional-comments").addClass("hide")

        _.each visible, @renderOneModalComment

    renderOneModalComment : (comment) =>

      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      @$modalComments.append JST["src/js/templates/comment/summary.jst"](vars)

    getModalComments : (e) =>
      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]
      button = $(e.currentTarget)
      button.button("loading")

      @getActivityComments(model, @modalCommentCollection).then (newComms) =>
        @addAllComments newComms
        @modalCommentCollection.add newComms
        @renderAllModalComments newComms
        button.button("complete")
      , =>
        button.button("complete")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'error'

    getModalLikers : (e) =>
      e.preventDefault()

      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]
      
      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikers
      model.likers.fetch()

    postModalComment : (e) =>

      e.preventDefault()

      return unless Parse.User.current()

      button = @$(e.currentTarget)
      activity = button.closest(".activity")
      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]

      @postComment activity, model