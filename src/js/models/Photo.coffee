define [
  'underscore'
  'backbone'
  "models/Property"
  "models/Unit"
], (_, Parse, Property, Unit) ->

  Photo = Parse.Object.extend "Photo",

    defaults:
      url             : ""
      property        : ""
      unit            : ""
      caption         : ""