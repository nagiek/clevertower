define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/list"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, ActivityView, i18nUser, i18nCommon) ->

  class ProfileActivityView extends Parse.View
  
    el: "#activity"
    
    initialize: (attrs) ->
      @current = attrs.current
      @$list = @$("ul")
      @listenTo @model.activity, "reset", @addAll

      @modal = false

    render: ->      
      if @model.activity.length > 0 then @addAll() else @model.activity.fetch()
      @
      

    # Activity
    # ---------
    addOne : (a) =>
      view = new ActivityView
        model: a
        liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
        onProfile: true
      @$list.append view.render().el

    addAll : =>
      @$list.html ""

      unless @model.activity.length is 0

        # Group by date.
        dates = @model.activity.groupBy (a) -> moment(a.createdAt).format("LL")
        _.each dates, (set, date) =>
          @$list.append "<li class='nav-header'>#{date}</li>"
          _.each set, @addOne
          @$list.append "<li class='divider clearfix'></li>"

      else 
        text = if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other @model.get("first_name") || @model.name()
        @$list.html '<li class="empty">' + text + '</li>'