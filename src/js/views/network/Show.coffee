define [
  "jquery"
  "underscore"
  "backbone"
  'models/Network'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/network/show'
], ($, _, Parse, Network, TenantView, i18nProperty, i18nCommon) ->

  class ShowNetworkView extends Parse.View
  
    el: "#main"
    
    initialize: (attrs) =>
      
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
      $(@el).html JST["src/js/templates/lease/show.jst"](vars)
      
      @$list = @$('ul.tenants')
      
      @tenants.fetch() if @tenants.length is 0
      @
      
      
    addOne : (t) =>
      @$("p.empty").text ''
      @$list.append (new TenantView(model: t)).render()

    addAll : =>
      @tenants.each @addOne