define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Post = Parse.Object.extend "Post",

    defaults:
      title       : ""
      body        : ""
      post_type   : "status"