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

  class ShowProfileView extends BaseIndexActivityView
  
    el: "#main"

    events:
      'click .edit-profile-picture'         : 'editProfilePicture'
      'click ul > li > a.content'           : 'showModal'
      "submit #profile-picture-upload-form" : 'save'
      # Activity events
      "click .like-button"                  : "likeOrLogin"
      "click .likers"                       : "showLikers"
      "submit form.new-comment-form"        : "getCommentDataToPost"

    initialize: (attrs) ->

      super

      @current = attrs.current

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


    # BaseIndex Linkers
    # ------------------

    getModelDataToShowInModal: (e) ->
      e.preventDefault()

      @modal = true
      data = $(e.currentTarget).parent().data()

      # Keep track of where we are, for subsequent navigation.
      # Convert the index to an array and find the "new" index.
       
      # This is using the cached results done in addAllActivity
      # @modalCollection = @model.activity.select (a) => a.get("property") and a.get("property").id is @model.id
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

      @postComment activity, data, model


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

          # Set the property, as we may have not included it for property-specific queries.
          if objs[0] and not objs[0].get "property"
            _.each objs, (o) => o.set "property", @model

          @model.activity.add objs

          # We may be getting non-related models at this point.
          @addAllActivity objs
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
      if @model.activity.length >= @activityCount then @trigger "view:exhausted"

    # addOneActivity : (activity) =>
    #   view = new ActivityView(model: activity, onProfile: false)
    #   @$activity.append view.render().el

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

      visible = @modalCollection = if collection instanceof ActivityList
        collection.select (a) =>
          a.get("property") and a.get("property").id is @model.id
      else 
        _.select collection, (a) =>
          a.get("property") and a.get("property").id is @model.id

      if visible.length > 0 then _.each visible, @addOneActivity
      else @$loading.html '<div class="empty">' + i18nProperty.tenant_empty.activity + '</div>'
