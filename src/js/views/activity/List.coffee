define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  'models/Comment'
  'views/helper/Alert'
  "i18n!nls/common"
  'templates/activity/list'
  'templates/comment/summary'
  'gmaps'
], ($, _, Parse, moment, Activity, Comment, Alert, i18nCommon) ->

  class ActivityListView extends Parse.View
    
    tagName: "li"
    className: "thumbnail clearfix activity fade in"
      
    events:
      "click .like-button"  : "likeOrLogin"
      "click .likers"       : "showLikers"
      "submit form"         : "postComment"

    initialize: (attrs) ->
      @liked          = attrs.liked           || false
      @currentProfile = attrs.currentProfile  || false
      @onProfile      = attrs.onProfile       || false

      @model.prep "comments"
      @model.prep "likers"
      @listenTo @model.comments, "reset", @addAll
      
      if Parse.User.current()
        # Check for likes.
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkIfLiked

      # Give the user the chance to contribute
      @listenTo Parse.Dispatcher, "user:login", => 
        # Check for likes.
        @listenTo Parse.User.current().get("profile").likes, "reset", @checkIfLiked
        @checkIfLiked()

    checkIfLiked: ->
      @markAsLiked() if Parse.User.current().get("profile").likes.find (l) => l.id is @model.id

    showLikers: (e) ->
      e.preventDefault()
      visible = @model.likers
      .chain()
      .select((c) => c.get("activity") and c.get("activity").id is @model.id)
      .map((c) => c.get("profile"))
      .value()

      if visible.length > 0
        profiles = _.uniq(visible, false, (v) -> v.id)
        $("#people-modal .modal-body").html "<ul class='list-unstyled' />"
        for p in profiles
          $("#people-modal .modal-body ul").append """
            <li class="clearfix">
              <div class="photo photo-thumbnail stay-left">
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

    likeOrLogin: (e) =>
      e.preventDefault()
      if Parse.User.current()
        if @liked
          @model.increment likeCount: -1
          @model.relation("likers").remove Parse.User.current().get("profile")
          Parse.User.current().get("profile").relation("likes").remove @model
          Parse.User.current().get("profile").likes.remove @model
          @$(".like-count").html(likes - 1)
          @$(".likers").removeClass("active")
          @$(".like-button").text i18nCommon.actions.like
          @liked = false
          Parse.Object.saveAll [@model, Parse.User.current().get("profile")]
          @clear() if @currentProfile
        else
          likes = @model.get "likeCount"
          @markAsLiked()
          @$(".like-count").text(likes + 1)
          @model.increment likeCount: +1
          @model.relation("likers").add Parse.User.current().get("profile")
          Parse.User.current().get("profile").relation("likes").add @model
          Parse.User.current().get("profile").likes.add @model
          @liked = true
          Parse.Object.saveAll [@model, Parse.User.current().get("profile")]
        
      else
        $("#signup-modal").modal()

    # Used just for display, not the action.
    markAsLiked: =>
      @$(".likers").addClass "active"
      @$(".like-button").text i18nCommon.adjectives.liked

    addOne : (comment) =>
      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      @$comments.append JST["src/js/templates/comment/summary.jst"](vars)
      
    addAll: (collection, filter) =>

      @$comments.html ""
      visible = @model.comments.select (c) => c.get("activity") and c.get("activity").id is @model.id

      if visible.length > 0 then _.each visible, @addOne

    postComment: (e) ->
      e.preventDefault()

      return unless Parse.User.current()

      data = @$form.serializeObject()

      return unless data.comment and data.comment.title

      # Use a pointer, to make sure we don't run into double-save issues.
      activity = 
        __type: "Pointer"
        className: "Activity"
        objectId: @model.id

      property = if @model.get("property")
        __type: "Pointer"
        className: "Property"
        objectId: @model.get("property").id
      else undefined

      network = if @model.get("network")
        __type: "Pointer"
        className: "Network"
        objectId: @model.get("network").id
      else undefined

      comment = new Comment
        title: data.comment.title
        center: @model.get "center"
        profile: Parse.User.current().get "profile"
        activity: activity
        property: property
        network: network

      # Optimistic saving.
      @addOne comment, true
      @$form.find("input").val("")
      newCount = @model.get("commentCount") + 1
      # Count is incremented in Comment afterSave
      @model.set "commentCount", newCount
      @$(".comment-count").html newCount

      comment.save().then (obj) -> , 
      (error) =>
        console.log error
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors.unknown, type: 'danger'
        @$comments.children().last().remove()
        @model.set "commentCount", newCount - 1
        @$(".comment-count").html newCount - 1

    render: ->
      vars = _.merge @model.toJSON(), 
        url: @model.url()
        start: moment(@model.get("startDate")).format("LLL")
        end: moment(@model.get("endDate")).format("LLL")
        postDate: moment(@model.createdAt).fromNow()
        liked: @liked
        postImage: @model.image("span4")
        icon: @model.icon()
        name: @model.name()
        profilePic: @model.profilePic("tiny")
        profileUrl: @model.get("profile").url()
        linkedToProperty: @model.linkedToProperty()
        pos: @pos % 20 # This will be incremented in the template.
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
      vars.title = @model.title()
      
      @$el.html JST["src/js/templates/activity/list.jst"](vars)

      @$comments = @$("ul.list-comments")
      @$form = @$("form.new-comment-form")

      if @model.comments.length > 0 then @addAll() else @model.comments.fetch()

      @checkIfLiked() if Parse.User.current()

      @

    clear: ->
      @remove()
      @undelegateEvents()
      delete this