define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/tenant/TenantList'
  'models/Unit'
  'models/Lease'
  'models/Tenant'
  'views/tenant/Summary'
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
  'templates/lease/show'
], ($, _, Parse, moment, TenantList, Unit, Lease, Tenant, TenantView, i18nUnit, i18nLease, i18nCommon) ->
  
  class ShowLeaseView extends Parse.View
    
    el: ".content"
    
    initialize: (attrs) =>
      @property = attrs.property
      
      @model.prep('tenants')
      
      @model.tenants.on "add",   @addOne
      @model.tenants.on "reset", @addAll
      
    # Re-render the contents of the Unit item.
    render: ->
      modelVars = @model.toJSON()
      
      # References
      unitId = @model.get("unit").id
      modelVars.propertyId = @property.id
      modelVars.unitId = unitId
      modelVars.title = @model.get("unit").get("title")
      modelVars.tenants = false
      
      # Parse turns dates into an object, which we must override.
      modelVars.start_date = moment(@model.get "start_date").format("LL")
      modelVars.end_date = moment(@model.get "end_date").format("LL")
      
      vars = _.merge(modelVars, i18nUnit: i18nUnit, i18nLease: i18nLease, i18nCommon: i18nCommon)
      @$el.html JST["src/js/templates/lease/show.jst"](vars)
      
      @$list = @$('ul#tenants')
      
      if @model.tenants.length is 0 then @model.tenants.fetch() else @addAll()
      @
      
    # We may have the network tenant list. Therefore, we must
    # be sure that we are only displaying relevant users.
    addOne : (t) =>
      console.log t
      console.log t.get("lease")
      if t.get("lease").id is @model.id
        @$("p.empty").text ''
        @$list.append (new TenantView(model: t)).render().el

    addAll : =>
      _.each @model.tenants.where(lease: @model), @addOne