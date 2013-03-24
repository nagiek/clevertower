define [
  "jquery"
  "underscore"
  "backbone"
  "collections/unit/UnitList"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "views/lease/New"
], ($, _, Parse, UnitList, Property, Unit, Lease, NewLeaseView, i18nCommon, i18nLease) ->

# define [
#   "models/Property"
#   "models/Lease"
# ], (Property, Lease) ->

  class AddLeaseToPropertyView extends Parse.View

    el: "#content"
  
    initialize : (attrs) ->
      @lease = new Lease property: @model
      @render()
      
    render : ->
      form = new NewLeaseView model: @lease, property: @model
    
    _return : ->
      @remove()
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"