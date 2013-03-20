define [
  'underscore'
  'backbone'
  "models/Property"
  "models/Unit"
], (_, Parse, Property, Unit) ->

  Lease = Parse.Object.extend "Lease",
  
    className: "Lease"

    defaults:

      rent:                   0
