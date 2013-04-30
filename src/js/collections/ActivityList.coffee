define [
  'jquery',
  'underscore',
  'backbone',
  'models/Activity'
], ($, _, Parse, Activity) ->

  class ActivityList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Activity

    query: new Parse.Query(Activity).include("property")

    initialize: (models, attrs) ->
      @profile = attrs.profile
      @query.equalTo("profile", @profile).descending("createdAt")
