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

      @$list = @$("> ul")
    
    render: ->      

      if @model.activities.length > 0 then @addAll else @model.activities.fetch()

      @
      

    # Activity
    # ---------
    addOne : (a) =>
      @$list.append (new ActivityView(model: a)).render().el

    addAll : =>
      @$list.html ""

      unless @model.activities.length is 0

        # Group by date.
        dates = @model.activities.groupBy (a) -> moment(a.createdAt).format("LL")
        _.each dates, (set, date) =>
          @$list.append "<li class='nav-header'>#{date}</li>"
          _.each set, @addOne
          @$list.append "<li class='divider'></li>"

      else @$list.html '<li class="empty">' + 
                                if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(name) +
                                '</li>'