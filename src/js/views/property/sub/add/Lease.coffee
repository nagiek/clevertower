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

  class AddLeaseToPropertyView extends Parse.View

    el: ".content"
  
    initialize : (attrs) ->
      
      @on "view:change", @clear
      
      vars = property: @model
      if attrs.params and attrs.params.unit
        @model.load('units')
        # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
        vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit
      @lease = new Lease(vars)
      
    render : ->
      @form = new NewLeaseView model: @lease, property: @model
    
    clear : ->
      delete @form.undelegateEvents()
      delete @form
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"