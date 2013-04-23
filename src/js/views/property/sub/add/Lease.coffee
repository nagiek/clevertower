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
      
      vars = property: @model, network: @model.get("network")
      if attrs.params and attrs.params.unit
        @model.prep('units')
        @model.units.fetch() if @model.units.length is 0
        # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
        vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit
      @lease = new Lease(vars)
      
    render : ->
      @form = new NewLeaseView(model: @lease, property: @model).render()
    
    clear : ->
      @form.undelegateEvents()
      delete @form
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"