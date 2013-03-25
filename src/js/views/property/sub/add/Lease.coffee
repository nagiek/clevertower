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
      vars = property: @model
      if attrs.params and attrs.params.unit
        @model.loadUnits()
        # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
        vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit
      @lease = new Lease(vars)
      @render()
      
    render : ->
      form = new NewLeaseView model: @lease, property: @model
    
    _return : ->
      @remove()
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"