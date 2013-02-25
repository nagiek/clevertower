define [
  'underscore',
  'backbone',
], (_, Parse) ->
  class UserModel extends Parse.User

    # Gets called automatically by Backbone when the set and/or save methods are called (Add your own logic)
    validate: (attrs) ->