define [
  'underscore'
  'backbone'
  'models/Lease'
], (_, Parse) ->

  Tenant = Parse.Object.extend "Tenant",
  
    defaults:
      status: "invited"