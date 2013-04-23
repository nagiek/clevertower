define [
  "jquery"
  "underscore"
  "backbone"
  "collections/unit/UnitList"
  "models/Property"
  "models/Unit"
  "models/Listing"
  "views/listing/New"
], ($, _, Parse, UnitList, Property, Unit, Listing, NewListingView, i18nCommon, i18nListing) ->

  class AddListingToPropertyView extends Parse.View

    el: ".content"
  
    initialize : (attrs) ->
      
      @on "view:change", @clear
      
      vars = property: @model, network: @model.get("network")
      if attrs.params and attrs.params.unit
        @model.prep('units')
        @model.units.fetch() if @model.units.length is 0
        # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
        vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit
      @listing = new Listing(vars)
      
    render : ->
      @form = new NewListingView(model: @listing, property: @model).render()
    
    clear : ->
      @form.undelegateEvents()
      delete @form
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"