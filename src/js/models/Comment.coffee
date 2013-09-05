define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Comment = Parse.Object.extend "Comment",

    className: "Comment"

    defaults:
      title:          ""

    # Display functions
    # -----------------

    name: -> @get('profile').name()
    profilePic: (size) -> @get('profile').cover(size)
    profileUrl: -> @get('profile').url()