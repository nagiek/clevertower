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

  class AddListingToLeaseView extends Parse.View

    el: ".content"
  
    initialize : (attrs) ->
      
      @on "view:change", @clear

      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork
      
      vars = 
        property: attrs.property
        unit: attrs.unit
        lease: attrs.lease
        network: attrs.property.get("network")
      
      @listing = new Listing(vars)
      
    render : ->
      @form = new NewListingView(model: @listing, property: @model, forNetwork: @forNetwork, baseUrl: @baseUrl).render()
      @
    
    clear : ->
      @form.stopListening()
      @form.undelegateEvents()
      delete @form
      @stopListening()
      @undelegateEvents()
      delete this
      Parse.history.navigate @baseUrl