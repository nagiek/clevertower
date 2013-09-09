define [
  'jquery'
  'underscore'
  'backbone'
  'models/Comment'
], ($, _, Parse, Comment) ->

  class CommentList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Comment

    initialize: (models, attrs) ->
      @query = new Parse.Query(Comment).descending("createdAt").include("profile").limit(500)

      # Activity List is very personal to the user.
      if attrs.property 
        @query.equalTo("property", attrs.property)
        @on "add", (a) -> a.set "property", attrs.property
        @on "reset", => _.each @models, (a) -> a.set "property", attrs.property
      else if attrs.network 
        @query.equalTo("network", attrs.network)
        @on "add", (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
        @on "reset", => _.each @models, (a) -> if a.get("property") then a.set "property", attrs.network.properties.find((p) -> a.get("property").id is p.id)
      else if attrs.profile then @query.equalTo("profile", attrs.profile).include("property")
      else if attrs.center and attrs.radius 
        @query
        .withinKilometers("center", attrs.center, attrs.radius)
        .notEqualTo("activity_type", "new_comment")
        .equalTo("public", true)

    setBounds: (sw, ne) -> @query.withinGeoBox('center', sw, ne)
    countByProperty: -> @countBy (a) -> a.get("property").id
    