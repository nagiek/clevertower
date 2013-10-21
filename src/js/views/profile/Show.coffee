define [
  "jquery"
  "underscore"
  "backbone"
  'infinity'
  "moment"
  "collections/ActivityList"
  "collections/CommentList"
  "models/Profile"
  "views/profile/sub/Activity"
  "views/activity/BaseIndex"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
  'templates/activity/modal'
  'templates/comment/summary'
], ($, _, Parse, infinity, moment, ActivityList, CommentList, Profile, ActivityView, BaseIndexActivityView, i18nUser, i18nCommon) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"

    events:
      'click .edit-profile-picture'         : 'editProfilePicture'
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

      @listenTo @model.likes, "reset", @updateLikesCount
      if @model.likes.length > 0 then @updateLikesCount() else @model.likes.fetch()

      @file = false

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    checkIfLiked: (activity) =>
      data = activity.data()

      model = @model.activity.at(data.index)

      @markAsLiked(activity) if Parse.User.current().get("profile").likes.find (l) => l.id is model.id

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

