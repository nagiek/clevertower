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
      
      vars = property: @model, network: @model.get("network")
      if attrs.params and attrs.params.unit
        @model.prep('units')
        @model.units.fetch() if @model.units.length is 0
        # vars.unit = @model.units.get attrs.params.unit # Won't complete in time
        vars.unit = __type: "Pointer", className: "Unit", objectId: attrs.params.unit
      @listing = new Listing(vars)
      
    render : ->
      @form = new NewListingView(model: @listing, property: @model, baseUrl: @baseUrl).render()
      @
    
    clear : ->
      @form.stopListening()
      @form.undelegateEvents()
      delete @form
      @stopListening()
      @undelegateEvents()
      delete this
      Parse.history.navigate @baseUrl