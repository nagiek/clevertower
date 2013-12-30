define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  "collections/ActivityList"
  "collections/CommentList"
  "collections/ProfileList"
  "models/Profile"
  "views/profile/Summary"
  "views/profile/sub/Activity"
  "views/activity/BaseIndex"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
  'templates/activity/modal'
  'templates/comment/summary'
], ($, _, Parse, infinity, moment, ActivityList, CommentList, ProfileList, Profile, SummaryProfileView, ActivityView, BaseIndexActivityView, i18nUser, i18nCommon) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"

    events:
      'click .edit-profile-picture'         : 'editProfilePicture'
      'click #stats-likes-link'             : 'swtichToLikesTab'
      'click #followers-link'               : 'showFollowers'
      'click #following-link'               : 'showFollowing'
      "submit #profile-picture-upload-form" : 'save'

    initialize: (attrs) ->

      super

      @current = attrs.current
      @subviews = {}

      @model.prep "comments"

      @listenTo @model, 'change:image_profile', @refresh
      # @listenTo Parse.Dispatcher, "user:logout", @switchToPublic

      unless @model.activity
        @model.activity = new ActivityList [], profile: @model

      unless @model.likes
        @model.likes = new ActivityList [], profile: @model
        @model.likes.query = @model.relation("likes").query().include("property")

      unless @model.following
        @model.following = new ProfileList [], {}
        @model.following.query = @model.relation("following").query()

      unless @model.followers
        @model.followers = new ProfileList [], {}
        @model.followers.query = @model.relation("followers").query()

      @listenTo @model.likes, "add",    @incLikesCount
      @listenTo @model.likes, "remove", @decLikesCount

      @on "profile:follow", (p) => _.each(@subviews, (view) -> view.trigger("profile:follow", p))
      @on "profile:unfollow", (p) => _.each(@subviews, (view) -> view.trigger("profile:unfollow", p))

      @file = false

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

    checkIfFollowing: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsFollowing(activity) if Parse.User.current().get("profile").following.find (p) => p.id is model.get("profile").id

    # switchToPublic: =>
    #   if @subView !instanceof ActivityView
    #     @current = false
    #     Parse.history.navigate "/users/#{@model.id}"
    #     @activeTab = "activity"
    #     @changeSubView @activeTab

    incLikesCount: (count) => 
      count = Number(@$("#like-count").html()) + 1
      @$("#like-count").html count

    decLikesCount: (count) =>
      count = Number(@$("#like-count").html()) - 1
      @$("#like-count").html count

    render: ->      
      vars = _.merge @model.toJSON(),
        cover: @model.cover 'profile'
        likesCount: @model.get("likesCount") || 0
        followersCount: @model.get("followersCount") || 0
        followingCount: @model.get("followingCount") || 0
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

      # Load the model if it exists.
      @$("##{@activeTab}-link").tab('show')

      unless @subviews[name] 
        require [name], (ProfileSubView) => 
          vars = params: params, model: @model, current: @current
          @subviews[name] = (new ProfileSubView(vars)).render()
      

    # Re-render the contents of the property item.
    refresh: ->
      @$('#profile-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      _.each @subviews, (subview) -> subview.clear()
      @undelegateEvents()
      @stopListening()
      delete this

    swtichToLikesTab: (e) -> 
      e.preventDefault()
      @$("#likes-link").click()
    showFollowers: (e) ->
      e.preventDefault()
      if @model.followers.length is 0 then @model.followers.fetch(add: true, success: @showFollowersModal) else @showFollowersModal(@model.followers)
    showFollowing: (e) ->
      e.preventDefault()
      if @model.following.length is 0 then @model.following.fetch(add: true, success: @showFollowingModal) else @showFollowingModal(@model.following)
    
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

    showFollowersModal: (collection) =>
      $("#people-modal h3.modal-title").html i18nCommon.activity.people_following(@model.name())
      if collection.length > 0
        $("#people-modal .modal-body").html "<ul class='list-unstyled' />"
        collection.each @appendPerson
      else
        $("#people-modal .modal-body").html "<p>#{i18nCommon.activity.following_no_one(@model.name())}</p>"
      $("#people-modal").modal()

    showFollowingModal: (collection) =>
      $("#people-modal h3.modal-title").html i18nCommon.activity.people_followed_by(@model.name())
      if collection.length > 0
        $("#people-modal .modal-body").html "<ul class='list-unstyled' />"
        collection.each @appendPerson
      else
        $("#people-modal .modal-body").html "<p>#{i18nCommon.activity.followed_by_no_one(@model.name())}</p>"
      $("#people-modal").modal()

    appendPerson: (p) =>
      view = new SummaryProfileView(model: p, view: @).render().$el
      $("#people-modal .modal-body ul").append view

    save: (e) =>
      e.preventDefault()
      if @file
        @model.save image_thumb: @file.url, image_profile: @file.url, image_full: @file.url
        @$('#edit-profile-picture-modal').modal('hide')
      else 
        @$form.after """
          <div class="alert alert-danger fade in">
            <p class="message">#{i18nCommon.errors.no_picture}</p>
          </div>
        """

