define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Tenant = Parse.Object.extend "Tenant",
  
    className: "Tenant"
  
    defaults:
      status: "invited"