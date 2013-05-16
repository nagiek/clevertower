define [
  'jquery',
  'underscore',
  'backbone',
  'models/Activity'
], ($, _, Parse, Activity) ->

  class ActivityList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Activity

    initialize: (models, attrs) ->
      @profile = attrs.profile
      @query = new Parse.Query(Activity).descending("createdAt")

      # Activity List is very personal to the user.
      if Parse.User.current().get("property") then @query.equalTo("property", Parse.User.current().get("property"))
      else if Parse.User.current().get("network") then @query.equalTo("network", Parse.User.current().get("network"))