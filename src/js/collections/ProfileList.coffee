define [
  'jquery'
  'underscore'
  'backbone'
  'models/Profile'
], ($, _, Parse, Profile) ->

  class ProfileList extends Parse.Collection
  
    # Reference to this collection's model.
    model: Profile

    initialize: (models, attrs) ->
      @query = new Parse.Query(Profile).include("property").include("location").descending("createdAt").limit(500)

      # Activity List is very personal to the user.
      if attrs.activity
        @query.equalTo("activity", attrs.activity)
        @on "add", (a) -> a.set "activity", attrs.activity
        @on "reset", => _.each @models, (a) -> a.set "activity", attrs.activity