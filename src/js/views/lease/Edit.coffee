define [
  "models/Lease"
  "views/lease/New"
  "templates/lease/new"
], (Lease, NewLeaseView) ->

  class EditLeaseView extends Parse.View
      
    initialize : (attrs) ->
      new Parse.Query("Lease").include("unit").get attrs.subId, 
      success: (model) => 
        new NewLeaseView(model: model, property: attrs.property)