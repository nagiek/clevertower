define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/tenant/TenantList'
  'models/Unit'
  'models/Lease'
  'views/tenant/Summary'
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
  'templates/lease/show'
], ($, _, Parse, moment, TenantList, Unit, Lease, TenantView, i18nUnit, i18nLease, i18nCommon) ->

  class ShowLeaseView extends Parse.View
  
    el: "#content"
    
    initialize: (attrs) ->
      @property = attrs.property
      @property.loadUnits()
      Parse.Promise.when([
        new Parse.Query("Lease").include("unit").get attrs.subId, success: (model) => 
          @model = model
          @tenants = new TenantList([], lease: @model)
          
          @tenants.on "add",   @addOne
          @tenants.on "reset", @addAll
          
          @tenants.fetch()
          # @rel_tenants_current = @model.relation("tenants_current")
          # @rel_tenants_current.on "add",   @addOneCurrent
          # @rel_tenants_current.on "reset", @addAllCurrent
          # @rel_tenants_current.query().find success: (list) => @tenants_current = list
          
        # new Parse.Query("Lease").relation.query().get attrs.subId, success: (model) => @model = model
        # new Parse.Query("Income").where("lease", attrs.subId)
        # new Parse.Query("Expense").where("lease", attrs.subId)
      ])
      .then =>
        @render()
        # @tenants_pending = _this.tenants_pending
        # @tenants_invited = _this.tenants_invited
        # @tenants_current = _this.tenants_current
      
    # Re-render the contents of the Unit item.
    render: ->
      modelVars = @model.toJSON()
      
      # References
      unitId = @model.get("unit").id
      modelVars.propertyId = @property.id
      modelVars.unitId = unitId
      modelVars.title = @model.get("unit").get("title") # @property.units.get(unitId).get("title")
      modelVars.tenants = false
      
      # Parse turns dates into an object, which we must override.
      modelVars.start_date = moment(@model.get "start_date").format("LL")
      modelVars.end_date = moment(@model.get "end_date").format("LL")
      
      vars = _.merge(modelVars, i18nUnit: i18nUnit, i18nLease: i18nLease, i18nCommon: i18nCommon)
      $(@el).html JST["src/js/templates/lease/show.jst"](vars)
      @
      
      
    addOne : (t) =>
      @$("p.empty").text ''
      new TenantView model: t

    addAll : =>
      @tenants.each @addOne