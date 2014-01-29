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

      @query = new Parse.Query(Activity)

      # Activity List is very personal to the user.
      if attrs.property 
        @property = attrs.property
        @query
        .equalTo("property", attrs.property)
        # .descending("createdAt")
        # .limit(100)
        # .include("object")
        @on "add", (a) -> a.set "property", attrs.property
        @on "reset", => _.each @models, (a) -> a.set "property", attrs.property
      else if attrs.network
        @query
        .equalTo("network", attrs.network)
        # .descending("createdAt")
        # .limit(100)
        # .include("object")
        @on "add", (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
        @on "reset", => _.each @models, (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
      else if attrs.subject
        @subject = attrs.subject
        @query
        .equalTo("subject", attrs.subject)
        .descending("createdAt")
        .include("property")
      else if attrs.object
        @object = attrs.object
        @query
        .equalTo("object", attrs.object)
        .descending("createdAt")
        .include("property")
      else if attrs.center and attrs.radius 
        @query
        .withinKilometers("center", attrs.center, attrs.radius)
        .containedIn("activity_type", ["new_property", "new_listing", "new_post"])
        .equalTo("public", true)
        # .descending("createdAt")
        # .limit(100)
        # .include("object")
        # .include("property")
      else 
        @query
        .containedIn("activity_type", ["new_property", "new_listing", "new_post"])
        .equalTo("public", true)
        # .limit(100)
        # .include("object")
        # .include("property")

    setBounds: (sw, ne) -> @query.withinGeoBox('center', sw, ne)
    countByProperty: -> @countBy (a) -> a.get("property").id
    