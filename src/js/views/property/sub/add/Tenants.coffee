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
      @vars = property: @model, lease: undefined, baseUrl: @baseUrl
      
      if attrs.params and attrs.params.lease
        @model.prep('leases')
        @model.leases.fetch() if @model.leases.length is 0
        @vars.leaseId = attrs.params.lease
      
      
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
      Parse.history.navigate @baseUrl