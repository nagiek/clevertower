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
      @query = new Parse.Query(Activity).descending("createdAt")

      # Activity List is very personal to the user.
      if attrs.property 
        @property = attrs.property
        @query.equalTo("property", attrs.property).limit(100).include("profile")
        @on "add", (a) -> a.set "property", attrs.property
        @on "reset", => _.each @models, (a) -> a.set "property", attrs.property
      else if attrs.network
        @query.equalTo("network", attrs.network).limit(100).include("profile")
        @on "add", (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
        @on "reset", => _.each @models, (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
      else if attrs.profile 
        @profile = attrs.profile
        @query.equalTo("profile", attrs.profile).include("property")
      else if attrs.center and attrs.radius 
        @query
        .withinKilometers("center", attrs.center, attrs.radius)
        .notEqualTo("activity_type", "new_comment")
        .equalTo("public", true)
        .limit(100)
        .include("profile")
        .include("property")

    setBounds: (sw, ne) -> @query.withinGeoBox('center', sw, ne)
    countByProperty: -> @countBy (a) -> a.get("property").id