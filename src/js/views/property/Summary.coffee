define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/summary'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertySummaryView extends Parse.View
  
    tagName: "li"
    className: "row"
  
    initialize: ->

      @model.prep('units')
      @model.prep('listings')
      @model.prep('tenants')

      @listenTo @model.units, 'add reset', @updateUnitCount
      @listenTo @model.listings, 'add reset', @updateListingCount
      @listenTo @model.tenants, 'add reset', @updateTenantCount

    updateUnitCount: => 
      units = @model.units.select((u) => u.get("property").id is @model.id)
      @$(".unit-count").html units.length
      @$(".vacant-count").html _.filter(units, (u) -> u.get("activeLease") is undefined).length
    updateListingCount: => @$(".listings-count").html @model.listings.select((l) => l.get("property").id is @model.id).length
    updateTenantCount: => @$(".tenants-count").html @model.tenants.select((t) => t.get("property").id is @model.id).length
      
    # show: (e) =>
    #   $('#main').append new ShowPropertyView(model:@model, e: e).render().el
    #   @model.collection.trigger 'show'
  
    # Re-render the contents of the property item.
    render: =>
      
      units = @model.units.select((u) => u.get("property").id is @model.id)

      vars = _.merge @model.toJSON(),
        cover:          @model.cover('profile')
        publicUrl:      @model.publicUrl()
        listings:       @model.listings.select((l) => l.get("property").id is @model.id).length
        tenants:        @model.tenants.select((t) => t.get("property").id is @model.id).length
        units:          units.length
        vacant_units:   _.filter(units, (u) -> u.get("activeLease") is undefined).length
        baseUrl:        "/properties/#{@model.id}"
        i18nProperty:   i18nProperty
        i18nCommon:     i18nCommon
      
      @$el.html JST["src/js/templates/property/summary.jst"](vars)
      @$("[rel=tooltip]").tooltip()
      @