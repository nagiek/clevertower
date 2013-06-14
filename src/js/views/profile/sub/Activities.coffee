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

      unless @model.activities.length is 0

        # Group by date.
        dates = @model.activities.groupBy (a) -> moment(a.createdAt).format("LL")
        _.each dates, (set, date) =>
          @$activityList.append "<li class='nav-header'>#{date}</li>"
          console.log set
          _.each set, @addOneActivity
          @$activityList.append "<li class='divider'></li>"

      else @$activityList.html '<li class="empty">' + 
                                if @current then i18nUser.empty.activities.self else i18nUser.empty.activities.other(name) +
                                '</li>'
