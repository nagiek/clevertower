define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Manager = Parse.Object.extend "Manager",
  
    className: "Manager"
  
    defaults:
      status: "invited"