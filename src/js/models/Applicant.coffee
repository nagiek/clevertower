define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Applicant = Parse.Object.extend "Applicant",
  
    className: "Applicant"
  
    defaults:
      status: "invited"