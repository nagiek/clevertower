define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  'collections/ActivityList'
  'collections/CommentList'
  "models/Comment"
  "views/helper/Alert"
  "views/profile/Summary"
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
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Comment, Alert, SummaryProfileView, ListingSearchView, NewActivityView, i18nListing, i18nCommon) ->

  class BaseActivityIndexView extends Parse.View
  
    el: "#main"

    events:
      'click .thumbnails a.content'             : 'getModelDataToShowInModal' # 'showModal'
      'click .thumbnails a.get-comments'        : 'getActivityCommentsAndCollection' # 'showModal'
      # Activity events
      "click .like-button"                      : "likeOrLoginFromActivity"
      "click .likers"                           : "getLikersFromActivity"
      # "click .follow-button"                    : "followOrLoginFromActivity"
      # "click .followers"                        : "getFollowersFromActivity"
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
        @listenTo Parse.User.current().get("profile").following, "reset", @checkForFollowing

        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()
        if Parse.User.current().get("profile").following.length is 0 then Parse.User.current().get("profile").following.fetch()

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

      @on "profile:follow", @markProfileActivitiesAsFollowing
      @on "profile:unfollow", @markProfileActivitiesAsNotFollowing

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
        @listenTo Parse.User.current().get("profile").following, "reset", @checkForFollowing

        # Get the user's personal likes.
        if Parse.User.current().get("profile").likes.length is 0 then Parse.User.current().get("profile").likes.fetch()
        if Parse.User.current().get("profile").following.length is 0 then Parse.User.current().get("profile").following.fetch()

    checkForLikes: ->
      Parse.User.current().get("profile").likes.each (l) =>
        _.each @listViews, (lv) =>
          activity = lv.find("> div > .activity-#{l.id}")
          if activity.length > 0
            @markAsLiked activity[0].$el
            # return {} to avoid checking the other column.
            {}

    checkForFollowing: =>
      Parse.User.current().get("profile").following.each @markProfileActivitiesAsFollowing

    markProfileActivitiesAsNotFollowing: (p) =>
      _.each @listViews, (lv) =>
        activity = lv.find("> div > .profile-#{p.id}")
        if activity.length > 0
          _.each activity, (a) => @markAsNotFollowing a.$el
          # return {} to avoid checking the other column.
          {}

    markProfileActivitiesAsFollowing: (p) =>
      _.each @listViews, (lv) =>
        activity = lv.find("> div > .profile-#{p.id}")
        if activity.length > 0
          _.each activity, (a) => @markAsFollowing a.$el
          # return {} to avoid checking the other column.
          {}

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

    renderTemplate: (model, likedByUser, followedByUser, linked) =>

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
      $el = $ "<div class='thumbnail clearfix activity activity-#{model.id} profile-#{model.get('subject').id} fade in' />"

        # data-id="#{model.id}"
        # data-liked="#{likedByUser}"
        # data-followedByUser="#{followedByUser}"
        # data-linked="#{linked}"
        # data-property-index="#{propertyIndex}" 
        # data-property-id="#{propertyId}"
        # data-index="#{model.pos()}"
        # data-lat="#{model.GPoint().lat()}"
        # data-lng="#{model.GPoint().lng()}"
        # data-collection="#{collection}"
        # data-subject="#{model.subject().cover("tiny")}"
        # data-object="#{model.object().cover("tiny")}"
        # data-image="#{model.image("full")}"

      $el.data
        id: model.id
        liked: likedByUser
        followedByUser: followedByUser
        linked: linked
        "property-index": propertyIndex
        "property-id": propertyId
        "location-id": if model.get("location") then model.get("location").id else false
        index: model.pos()
        lat: model.GPoint().lat()
        lng: model.GPoint().lng()
        collection: collection
        subject: model.subject().cover("tiny")
        object: if model.object() then model.object().cover("tiny")
        image: model.image("full")

      vars = _.merge model.toJSON(), 
        url: model.url()
        linkedToProperty: linked
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        postImage: model.image("full") # Keep this in for template logic.
        subjectUrl: model.subject().url()
        objectUrl: if model.object() then model.object().url()
        icon: model.icon()
        name: model.subject().name()
        likedByUser: likedByUser
        followedByUser: followedByUser
        current: Parse.User.current()
        isSelf: collection is "user" or (Parse.User.current() and model.get("subject").id is Parse.User.current().get("profile").id)
        i18nCommon: i18nCommon
        pos: if @onMap then (if linked then propertyIndex else model.pos()) % 20 else false # This will be incremented in the template.
        wideAudience: model.get("wideAudience")

      if model.get("activity")
        vars.activity = true
        vars.activityImage = model.get("activity").image("full")
        vars.title = model.get("activity").title()
        vars.subtitle = model.title()
      else
        vars.title = model.title()
        vars.subtitle = false

      if Parse.User.current()
        vars.self = Parse.User.current().get("profile").name()
        vars.selfCover = Parse.User.current().get("profile").cover("tiny")

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likersCount: 0
        commentCount: 0

      $el.html JST["src/js/templates/activity/summary.jst"](vars)

      if Parse.User.current()
        @checkIfLiked($el) unless likedByUser
        @checkIfFollowing($el) unless followedByUser

      $el

    addOneActivity: (a) =>
      # view = new ActivityView
      #   model: a
      #   view: @
      #   liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
      # @listViews[@shortestColumnIndex()].append view.render().$el
      @listViews[@shortestColumnIndex()].append @renderTemplate(a, a.likedByUser(), a.subject().followedByUser(), false)
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

    like : (model, activity, button, data, undo) =>
      likes = Number activity.find(".likers-count").html()
      
      if data.liked
        button.removeClass "active"
        activity.find(".likers-count").html(likes - 1)
        @markAsUnliked activity
        # activity.attr "data-liked", "false"

        Parse.User.current().get("profile").increment likesCount: -1
        Parse.User.current().get("profile").relation("likes").remove model
        Parse.User.current().get("profile").likes.remove model

        unless undo 
          Parse.Cloud.run "Unlike", {
            likee: model.id
            liker: Parse.User.current().get("profile").id
          },
          error: (res) => 
            # Undo what we did.
            @like(model, activity, button, data, true)
            console.log res
        else new Alert event: 'like', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'
        
      else
        button.addClass "active"
        activity.find(".likers-count").html(likes + 1)
        @markAsLiked activity

        Parse.User.current().get("profile").increment likesCount: -1
        Parse.User.current().get("profile").relation("likes").add model
        # Adding to a relation will somehow add to collection..?
        Parse.User.current().get("profile").likes.add model
        
        unless undo 
          Parse.Cloud.run "Like", {
            likee: model.id
            liker: Parse.User.current().get("profile").id
          },
          # Optimistic saving.
          # success: (res) => 
          error: (res) => 
            # Undo what we did.
            @like(model, activity, button, data, true)
            console.log res
        else new Alert event: 'like', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'

      Parse.User.current().get("profile").save()

    showLikersModal: (collection) =>
      $("#people-modal h3.modal-title").html i18nCommon.activity.people_who_like_this
      if collection.length > 0
        $("#people-modal .modal-body").html "<ul class='list-unstyled' />"
        collection.each @appendPerson
      else
        $("#people-modal .modal-body").html "<p>#{i18nCommon.activity.be_the_first_to_like_this}</p>"
      $("#people-modal").modal()

    appendPerson: (p) =>
      view = new SummaryProfileView(model: p, view: @).render().$el
      $("#people-modal .modal-body ul").append view

    # Used just for display, not the action.
    markAsLiked: (activity) ->
      activity.find(".likers").addClass "active"
      activity.find(".like-button").text i18nCommon.adjectives.liked
      activity.data "liked", true
      # activity.attr "data-liked", "true"

    markAsUnliked: (activity) ->
      activity.find(".likers").removeClass "active"
      activity.find(".like-button").text i18nCommon.actions.like
      activity.data "liked", false
      # activity.attr "data-liked", "false"


    follow : (model, activity, buttonParent, data, undo) =>

      if data.followedByUser
        buttonParent.html """<button type="button" class="btn btn-primary follow">#{i18nCommon.actions.follow}</button>"""
        @markAsNotFollowing(activity)

        Parse.User.current().get("profile").increment followingCount: -1
        Parse.User.current().get("profile").relation("following").remove model.get("subject")
        Parse.User.current().get("profile").following.remove model.get("subject")

        # Unfollow all other items from this profile
        @markProfileActivitiesAsNotFollowing(model.get("subject"))

        # activity.attr "data-liked", "false"
        unless undo
          Parse.Cloud.run "Unfollow", {
            followee: model.get("subject").id
            follower: Parse.User.current().get("profile").id
          },
          # Optimistic saving.
          # success: (res) => 
          error: (res) => 
            # Undo what we did.
            @follow(model, activity, buttonParent, data, true)
            console.log res
        else new Alert event: 'like', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'

      else
        # extra span to break up .btn + .btn spacing
        # Don't put in the unfollow button right away.
        buttonParent.html("""<span class="btn btn-primary following">#{i18nCommon.verbs.following}</span>""")
        setTimeout ->
          buttonParent.append """
            <span></span> 
            <button type="button" class="btn btn-default follow unfollow">#{i18nCommon.actions.unfollow}</button>
          """
        , 500

        @markAsFollowing(activity)

        Parse.User.current().get("profile").increment followingCount: +1
        Parse.User.current().get("profile").relation("following").add model.get("subject")
        # Adding to a relation will somehow add to collection..?
        Parse.User.current().get("profile").following.add model.get("subject")

        unless undo
          Parse.Cloud.run "Follow", {
            followee: model.get("subject").id
            follower: Parse.User.current().get("profile").id
          },
          # Optimistic saving.
          # success: (res) => 
          error: (res) => 
            # Undo what we did.
            @follow(model, activity, buttonParent, data, true)
            console.log res
        else new Alert event: 'like', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'
        
        # Follow all other items from this profile
        @markProfileActivitiesAsFollowing(model.get("subject"))

      Parse.User.current().get("profile").save()

    markAsNotFollowing: (activity) =>
      # activity.find(".follow-button").text i18nCommon.verbs.following
      activity.data "followedByUser", false

    markAsFollowing: (activity) =>
      # activity.find(".follow-button").text i18nCommon.verbs.following
      activity.data "followedByUser", true

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
          # return {} to avoid checking the other column.
          {}

      activity.find("input.comment-title").val("")

      # Count is incremented in Comment afterSave
      newCount = Number(model.get("commentCount")) + 1
      model.set "commentCount", newCount
      # activity.find(".comment-count").html newCount

      comment.save().then @addCommentToCollection, 
      (error) =>
        console.log error
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors.unknown, type: 'danger'
        model.set "commentCount", newCount - 1
        activity.find(".comments > li:last-child").remove()
        activity.find(".comment-count").html newCount - 1

      comment

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
      $('#view-content-modal').on 'click', 'button.follow', @followOrLoginFromModal
      $('#view-content-modal').on 'click', 'button.get-comments', @getModalComments
      $('#view-content-modal').on 'click', '.left', @prevModal
      $('#view-content-modal').on 'click', '.right', @nextModal
      $('#view-content-modal').on 'hide.bs.modal', @hideModal
      $('#view-content-modal').on 'click', 'a.like-button', @likeOrLoginFromModal
      $('#view-content-modal').on 'click', 'a.likers', @getLikersFromModal
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
      $('#view-content-modal').off "hide.bs.modal click submit"
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
      property = if model.get("property") then model.get("property") else false
      location = if model.get("location") then Parse.App.locations.find((l) -> l.id is model.get("location").id) else false

      vars = _.merge model.toJSON(), 
        url: model.url()
        subjectUrl: model.subject().url()
        objectUrl: if model.object() then model.object().url()
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        likedByUser: model.likedByUser()
        followedByUser: model.subject().followedByUser()
        postImage: model.image("full")
        icon: model.icon()
        name: model.subject().name()
        cover: model.subject().cover("thumb")
        propertyLinked: if property then true else false
        propertyTitle: if property then property.get("profile").name() else false
        propertyCover: if property then property.get("profile").cover("tiny") else false
        propertyUrl: if property then property.publicUrl() else false
        locationTitle: if location then location.get("profile").name() else false
        locationCover: if location then location.get("profile").cover("tiny") else false
        locationUrl: if location then location.url() else false
        current: Parse.User.current()
        isSelf: Parse.User.current() and model.get("subject").id is Parse.User.current().get("profile").id
        i18nCommon: i18nCommon
        wideAudience: model.get("wideAudience")

      if model.get("activity")
        vars.activity = true
        vars.activityImage = model.get("activity").image("full")
        vars.title = model.get("activity").title()
        vars.subtitle = model.title()
      else
        vars.title = model.title()
        vars.subtitle = false

      if Parse.User.current()
        vars.self = Parse.User.current().get("profile").name()
        vars.selfCover = Parse.User.current().get("profile").cover("tiny")

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likersCount: 0
        commentCount: 0

      $("#view-content-modal").html JST["src/js/templates/activity/modal.jst"](vars)

      $("#view-content-modal").find("> .modal-dialog > .activity").data
        liked: model.likedByUser()
        followedByUser: model.subject().followedByUser()

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
        cover: comment.cover("tiny")
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
        button.button("reset")
      , =>
        button.button("reset")
        new Alert event: 'comment-load', fade: false, message: i18nCommon.errors.comment_load, type: 'error'

    likeOrLoginFromModal: (e) =>
      e.preventDefault()
      button = $(e.currentTarget)
      activity = button.closest(".activity")
      data = activity.data()

      likes = Number activity.find(".likers-count").html()

      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]

      if Parse.User.current()
        @like model, activity, button, data, false

        # Update our non-modal activity as well.
        _.each @listViews, (lv) =>
          otherActivity = lv.find("> div > .activity-#{model.id}")
          if otherActivity.length > 0
            $otherActivity = otherActivity[0].$el

            # Data is switched at this point, so reverse the if-block conditions order. 
            if data.liked
              $otherActivity.find(".like-button").addClass "active"
              $otherActivity.find(".likers-count").html(likes + 1)
              @markAsLiked $otherActivity
              
            else
              $otherActivity.find(".like-button").removeClass "active"
              $otherActivity.find(".likers-count").html(likes - 1)
              @markAsUniked $otherActivity

            # return false to avoid checking the other column.
            false
        
      else
        $("#signup-modal").modal()

    getLikersFromModal : (e) =>
      e.preventDefault()

      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]
      
      model.prep("likers")
      @listenToOnce model.likers, "reset", @showLikersModal
      model.likers.fetch()

    postModalComment : (e) =>

      e.preventDefault()

      return unless Parse.User.current()

      form = $(e.currentTarget)
      activity = form.closest(".activity")
      model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]

      comment = @postComment activity, model
      # postComment will actually do this for us.
      # @renderOneModalComment comment


    followOrLoginFromModal : (e) =>
      e.preventDefault()
      if Parse.User.current()
        buttonParent = $(e.currentTarget).parent()
        activity = buttonParent.closest(".activity")
        data = activity.data()
        model = if @modalCollection instanceof ActivityList then @modalCollection.at @modalIndex else @modalCollection[@modalIndex]

        @follow model, activity, buttonParent, data, false
      else
        $("#signup-modal").modal()