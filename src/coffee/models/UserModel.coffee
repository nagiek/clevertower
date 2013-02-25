define [
  'underscore',
  'parse',
  'backbone',
], (_, Parse, Backbone) ->
  class UserModel extends Parse.User
    defaults:
      query: "unknown"

    initialize: (options) ->
      @query = options.query

    url: ->
      "https://api.github.com/users/" + @query

    parse: (res) ->

      # because of jsonp 
      res.data
