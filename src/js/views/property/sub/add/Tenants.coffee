define [
  "jquery"
  "underscore"
  "backbone"
  "collections/UnitList"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "views/tenant/New"
], ($, _, Parse, UnitList, Property, Unit, Lease, NewTenantsView, i18nCommon, i18nLease) ->

  class AddTenantsToPropertyView extends Parse.View

    el: ".content"
  
    initialize : (attrs) ->
      
      @on "view:change", @clear
      
      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork

      @vars = property: @model, profile: @model.get("profile"), lease: undefined, baseUrl: @baseUrl, forNetwork: @forNetwork
      
      if attrs.params and attrs.params.leaseId
        @vars.leaseId = attrs.params.leaseId
      
      
    render : ->
      @form = new NewTenantsView(@vars).render()
      @
    
    clear : ->
      @form.stopListening()
      @form.undelegateEvents()
      delete @form
      @stopListening()
      @undelegateEvents()
      delete this