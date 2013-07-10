define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/list"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, ActivityView, i18nUser, i18nCommon) ->

  class ProfileActivitiesView extends Parse.View
  
    el: "#activities"
    
    initialize: (attrs) ->
      @current = attrs.current
      @model.prep('activities')
      @listenTo @model.activities, "reset", @addAll

    render: ->      

      if @model.activities.length > 0 then @addAll else @model.activities.fetch()
      @$list = @$("> ul")
      @
      

    # Activity
    # ---------
    addOne : (a) =>
      view = new ActivityView
        model: a
        liked: Parse.User.current() and Parse.User.current().get("profile").likes.find (l) -> l.id is a.id
      @$list.append view.render().el

    addAll : =>
      @$list.html ""

      unless @model.activities.length is 0

        # Group by date.
        dates = @model.activities.groupBy (a) -> moment(a.createdAt).format("LL")
        _.each dates, (set, date) =>
          @$list.append "<li class='nav-header offset2'>#{date}</li>"
          _.each set, @addOne
          @$list.append "<li class='divider clearfix'></li>"

      else @$list.html '<li class="empty">' + 
                                if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(name) +
                                '</li>'