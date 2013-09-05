define [
  "jquery"
  "underscore"
  "backbone"
  "collections/UnitList"
  "models/Property"
  "models/Unit"
  "models/Listing"
  "views/listing/New"
], ($, _, Parse, UnitList, Property, Unit, Listing, NewListingView, i18nCommon, i18nListing) ->

  class AddListingToPropertyView extends Parse.View

    el: ".content"
  
    initialize : (attrs) ->
      
      @on "view:change", @clear

      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork
      @params = attrs.params
      
      vars = property: @model, network: @model.get("network")
      if attrs.params and  attrs.params.unit
          # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
          vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit.id
      @listing = new Listing(vars)
      
    render : ->
      vars = 
        model: @listing
        property: @model
        baseUrl: @baseUrl
        forNetwork: @forNetwork
      if @params then vars.unitId = @params.unitId
      @form = new NewListingView(vars).render()
      @
    
    clear : ->
      @form.stopListening()
      @form.undelegateEvents()
      delete @form
      @stopListening()
      @undelegateEvents()
      delete this
      Parse.history.navigate @baseUrl