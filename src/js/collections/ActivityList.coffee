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
      @query = new Parse.Query(Activity).descending("createdAt").include("profile")

      # Activity List is very personal to the user.
      if attrs.property then @query.equalTo("property", attrs.property)
      else if attrs.network then @query.equalTo("network", attrs.network)
      else if attrs.profile then @query.equalTo("profile", attrs.profile).include("property")
      else if attrs.center and attrs.radius 
        @query
        .withinKilometers("center", attrs.center, attrs.radius)
        .equalTo("public", true)

    setBounds: (sw, ne) -> @query.withinGeoBox('center', sw, ne)