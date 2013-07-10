define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  "i18n!nls/common"
  'templates/activity/list'
  'gmaps'
], ($, _, Parse, moment, Activity, i18nCommon) ->

  class ActivityListView extends Parse.View
    
    tagName: "li"
    className: "thumbnail clearfix activity fade in span4 offset2"

    events:
      "click .like-button"  : "likeOrLogin"
      # "click a" : "goToProperty"

    initialize: (attrs) ->
      @liked = attrs.liked || false
      @currentProfile = attrs.currentProfile || false
      
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

    likeOrLogin: (e) =>
      if Parse.User.current()
        unless @liked
          likes = @$(".like-count").html()
          @markAsLiked()
          @$(".like-count").html(likes + 1)
          @model.increment likeCount: +1
          Parse.User.current().get("profile").relation("likes").add @model
          Parse.User.current().get("profile").likes.add @model
          @liked = true
          Parse.Object.saveAll [@model, Parse.User.current().get("profile")]
        else
          @model.increment likeCount: -1
          @$(".like-count").html(likes - 1)
          Parse.User.current().get("profile").relation("likes").remove @model
          Parse.User.current().get("profile").likes.remove @model
          @liked = false
          Parse.Object.saveAll [@model, Parse.User.current().get("profile")]
          @clear() if @currentProfile
        
      else
        $("#signup-modal").modal()

    markAsLiked: -> @$(".like-button").addClass "active"

    clear: ->
      @undelegateEvents()
      @remove()
      delete this

    # Re-render the contents of the Unit item.
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
        pos: @pos % 20 # This will be incremented in the template.
        i18nCommon: i18nCommon

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

      @checkIfLiked() if Parse.User.current()

      @