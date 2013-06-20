define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/summary'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertySummaryView extends Parse.View
  
    tagName: "li"
    className: "row"
  
    initialize: ->
      
      # @listenTo @model.collection, 'show', @undelegateEvents
      # @listenTo @model.collection, 'close', @delegateEvents
      @listenTo @model, "change", @render
      
    # show: (e) =>
    #   $('#main').append new ShowPropertyView(model:@model, e: e).render().el
    #   @model.collection.trigger 'show'
  
    # Re-render the contents of the property item.
    render: =>
      
      vars = _.merge @model.toJSON(),
        cover        : @model.cover('profile')
        publicUrl    : @model.publicUrl()
        # Convert to collections.
        listings     : '0'            # @model.listings()
        incomes      : '0'            # @model.incomes().sum()
        expenses     : '0'            # @model.expenses().sum()
        vacant_units : '0'            # @model.units().vacant().length
        # units        : '0'            # @model.units().length
        unitsLength: if @model.unitsLength then @model.unitsLength else 0
        baseUrl: "/properties/#{@model.id}"
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      
      @$el.html JST["src/js/templates/property/summary.jst"](vars)
      @$("[rel=tooltip]").tooltip()
      @