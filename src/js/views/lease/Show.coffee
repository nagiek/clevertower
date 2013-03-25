define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Unit'
  'models/Lease'
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
  'templates/lease/show'
], ($, _, Parse, moment, Unit, Lease, i18nUnit, i18nLease, i18nCommon) ->

  class ShowLeaseView extends Parse.View
  
    el: "#content"
    
    initialize: (attrs) ->
      @property = attrs.property
      @property.loadUnits()
      Parse.Promise.when([
        new Parse.Query("Lease").get attrs.subId, success: (model) => @model = model
        # new Parse.Query("Lease").relation.query().get attrs.subId, success: (model) => @model = model
        # new Parse.Query("Income").where("lease", attrs.subId)
        # new Parse.Query("Expense").where("lease", attrs.subId)
      ])
      .then(model, tenants, incomes, expenses) =>
        @render()
      
      
    # Re-render the contents of the Unit item.
    render: ->
      
      modelVars = @model.toJSON()
      
      # References
      unitId = @model.get("unit").id
      modelVars.propertyId = @property.id
      modelVars.unitId = unitId
      modelVars.title = @property.units.get(unitId).get("title")
      modelVars.tenants = false
      
      # Parse turns dates into an object, which we must override.
      modelVars.start_date = moment(@model.get "start_date").format("LL")
      modelVars.end_date = moment(@model.get "end_date").format("LL")
      
      vars = _.merge(modelVars, i18nUnit: i18nUnit, i18nLease: i18nLease, i18nCommon: i18nCommon)
      $(@el).html JST["src/js/templates/lease/show.jst"](vars)
      @