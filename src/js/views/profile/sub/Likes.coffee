define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/list"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, ActivityView, i18nUser, i18nCommon) ->

  class ProfileLikesView extends Parse.View
  
    el: "#likes"
    
    initialize: (attrs) ->
      @current = attrs.current

      unless @model.likes
        @model.likes = new ActivityList([], {})
        @model.likes.query = @model.relation("likes").query()
      @listenTo @model.likes, "reset", @addAll
    
    render: ->      

      if @model.likes.length > 0 then @addAll else @model.likes.fetch()
      @$list = @$("> ul")
      @
      
    # Activity
    # ---------
    addOne : (a) =>
      view = new ActivityView
        model: a
        liked: @current or (Parse.User.current() and Parse.User.current().get("profile").likes.contains a)
        currentProfile: @current
      @$list.append view.render().el

    addAll : =>
      @$list.html ""

      unless @model.likes.length is 0
        @model.likes.each @addOne
      else @$list.html '<li class="empty">' + 
                                if @current then i18nUser.empty.likes.self else i18nUser.empty.likes.other(name) +
                                '</li>'