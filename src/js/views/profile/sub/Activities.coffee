define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/Summary"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, ActivityView, i18nUser, i18nCommon) ->

  class ProfileActivitiesView extends Parse.View
  
    el: "#activities"
    
    initialize: (attrs) ->

      @current = attrs.current
      @tab = attrs.tab || "activity"

      @model.prep('activities')
      @model.activities.on "reset", @addAllActivities

      if @current
        @model.prep('applicants')
        @model.applicants.on "reset", @addAllInquiries

      @$activityList = @$("> ul")
    
    render: ->      

      if @model.activities.length > 0 then @addAllActivities else @model.activities.fetch()

      @
      

    # Activity
    # ---------
    addOneActivity : (a) =>
      @$activityList.append (new ActivityView(model: a)).render().el

    addAllActivities : =>
      @$activityList.html ""
      dates = _.uniq @model.activities.map (a) -> a.createdAt.toDateString()

      unless @model.activities.length is 0
        @$activityList.find(".empty").remove()

        # Group by date.
        dates = @model.activities.filter (a) -> a.createdAt
        _.each dates, (date) =>
          @$activityList.append "<li class='nav-header'>#{moment(date).format("L")}</li>"
          _.each @model.activities.filter((a) -> a.createdAt.toDateString() is date.toDateString()), @addOneActivity
          @$activityList.append "<li class='divider'></li>"

      else @$activityList.html '<li class="empty">' + 
                                if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(name) +
                                '</li>'
