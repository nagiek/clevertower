define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/ActivityList"
  "models/Profile"
  "views/profile/sub/Activity"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
  'templates/activity/modal'
  'templates/comment/summary'
], ($, _, Parse, moment, ActivityList, Profile, ActivityView, i18nUser, i18nCommon) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"

    events:
      'click .edit-profile-picture'         : 'editProfilePicture'
      'click ul > li > a.content'           : 'showModal'
      "submit #profile-picture-upload-form" : 'save'
      # Activity events
      "click .like-button"                  : "likeOrLogin"
      "click .likers"                       : "showLikers"
      "submit form.new-comment-form"        : "postComment"

    initialize: (attrs) ->

      @current = attrs.current

      @model.prep "activity"
      @model.prep "comments"

      @listenTo @model, 'change:image_profile', @refresh
      # @listenTo Parse.Dispatcher, "user:logout", @switchToPublic

      unless @model.likes
        @model.likes = new ActivityList [], profile: @model
        @model.likes.query = @model.relation("likes").query().include("property")

      @listenTo @model.likes, "reset", @updateLikesCount
      if @model.likes.length > 0 then @updateLikesCount() else @model.likes.fetch()

      @file = false

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # switchToPublic: =>
    #   if @subView !instanceof ActivityView
    #     @current = false
    #     Parse.history.navigate "/users/#{@model.id}"
    #     @activeTab = "activity"
    #     @changeSubView @activeTab

    updateLikesCount: => 
      @$("#like-count").html @model.likes.length

    render: ->      
      vars = _.merge @model.toJSON(),
        cover: @model.cover 'profile'
        likeCount: @model.likes.length
        name: @model.name()
        i18nUser: i18nUser
        i18nCommon: i18nCommon
        current: @current
        joinDate: moment(@model.createdAt).format("LL")
      
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/profile/show.jst"](vars)
      @$form = @$("#profile-picture-upload-form")

      @

    changeSubView: (path, params) ->

      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")

      @activeTab = path || "activity"
      name = "views/profile/sub/#{@activeTab}"
      
      vars = params: params, model: @model, current: @current

      # Load the model if it exists.
      @$("##{@activeTab}-link").tab('show')
      @renderSubView name, vars

    renderSubView: (name, vars) ->
      @subView.trigger "view:change" if @subView
      require [name], (ProfileSubView) =>
        @subView = (new ProfileSubView(vars)).render()

    # Re-render the contents of the property item.
    refresh: ->
      @$('#profile-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      @undelegateEvents()
      @stopListening()
      Parse.history.navigate "", true
      delete this
    
    editProfilePicture: ->
      
      _this = @ # Keep for below

      require ['jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-pr'],  =>
        
        # Initiate the file upload.
        @$form.fileupload
          autoUpload: true
          type: "POST"
          dataType: "json"
          # fileInput: '#file-input'
          filesContainer: _this.$('#preview-profile-picture')
          multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
          context: @$form[0]
          submit: (e, data) ->
            data.url = "https://api.parse.com/1/files/" + data.files[0].name
          send: (e, data) ->
            delete data.headers['Content-Disposition']; # Parse does not accept this header.
          done: (e, data) ->
            _this.file = data.result

            # Defer to our photo rendering method.
            that = _this.$(this).data("blueimp-fileupload") or $(this).data("fileupload")
            that._transition(data.context)
            
            # data.context.each (index) ->
            #   node = $(this)
            #   that._transition(node).done ->
            #     node.remove()

            _this.$('#preview-profile-picture img').prop('src', _this.file.url)

            
        @$('#edit-profile-picture-modal').modal()

    save: (e) =>
      e.preventDefault()
      if @file
        @model.save image_thumb: @file.url, image_profile: @file.url, image_full: @file.url
        @$('#edit-profile-picture-modal').modal('hide')
      else 
        @$form.after """
          <div class="alert alert-block alert-error fade in">
            <p class="message">#{i18nCommon.errors.no_picture}</p>
          </div>
        """

    undelegateEvents : =>
      @detachModalEvents() if @modal
      super


    # Activities
    # ----------

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
        
      else
        $("#signup-modal").modal()

    checkIfLiked: ->
      @markAsLiked() if Parse.User.current().get("profile").likes.find (l) => l.id is @model.id

    # Used just for display, not the action.
    markAsLiked: =>
      @$(".likers").addClass "active"
      @$(".like-button").text i18nCommon.adjectives.liked

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
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors.unknown, type: 'error'
        @$comments.children().last().remove()
        @model.set "commentCount", newCount - 1
        @$(".comment-count").html newCount - 1


    # Modal
    # @see profile:show and property:public
    # --------------------------------------------

    showModal : (e) =>
      e.preventDefault()
      @modal = true
      @index = 0


      # Find out which tab was active, so we only show models from that tab.
      @collection = @model[@activeTab].select((a) => a.get("profile") and a.get("profile").id is @model.id)
      # Find the model in the collection, while simultaneously recording the index of our new array.
      data = $(e.currentTarget).data()
      model = _.find @collection, (f) => @index++; f.id is data.id
      # Correct for auto-increment
      @index -= 1
      @renderModalContent model
      $("#view-content-modal").modal(keyboard: false)
      
      # Add events.
      $(document).on "keydown", @controlModalIfOpen
      $('#view-content-modal').on 'click', '.caption a', @closeModal
      $('#view-content-modal').on 'click', '.left', @prevModal
      $('#view-content-modal').on 'click', '.right', @nextModal
      $('#view-content-modal').on 'hide.bs.modal', @hideModal
      $('#view-content-modal').on 'click', '.like-button', @likeOrLogin
      $('#view-content-modal').on 'click', '.likers', @showLikers
      $('#view-content-modal').on 'submit', 'form', @postComment

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

    detachModalEvents : ->
      $(document).off "keydown"
      $('#view-content-modal').off "hide click submit"
      # $('#view-content-modal .caption a').off 'click'
      # $('#view-content-modal .left').off 'click'
      # $('#view-content-modal .right').off 'click'

    nextModal : =>
      return unless @modal
      @index++
      if @index >= @collection.length then @index = 0
      @renderModalContent @collection[@index]

    prevModal : =>
      return unless @modal
      @index--
      if @index < 0 then @index = @collection.length - 1
      @renderModalContent @collection[@index]

    renderModalContent : (model) =>

      # Add a building link if applicable.
      # Cache result
      property = if model.linkedToProperty() then model.property() else false

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
      @$comments = $("#view-content-modal .list-comments")
      @$comments.html ""
      visible = model.comments.select (c) => c.get("activity") and c.get("activity").id is model.id
      if visible.length > 0 then _.each visible, @renderOneModalComment

    renderOneModalComment : (comment) =>

      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      @$comments.append JST["src/js/templates/comment/summary.jst"](vars)