define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Concierge = Parse.Object.extend "Concierge",
  
    className: "Concierge"
  
    defaults:
      status: "pending"