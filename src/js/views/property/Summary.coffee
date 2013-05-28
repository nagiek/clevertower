define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "views/property/Show"
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/summary'
], ($, _, Parse, Property, ShowPropertyView, i18nProperty, i18nCommon) ->

  class PropertySummaryView extends Parse.View
  
    tagName: "li"
    className: "row"
  
    initialize: ->
      
      # @model.collection.on 'show', => @undelegateEvents()
      # @model.collection.on 'close', => @delegateEvents()
      @listenTo @model, "change", @render
      
    # show: (e) =>
    #   $('#main').append new ShowPropertyView(model:@model, e: e).render().el
    #   @model.collection.trigger 'show'
  
    # Re-render the contents of the property item.
    render: =>
      details = 
        cover        : @model.cover('profile')
        publicUrl    : @model.publicUrl()
        # Convert to collections.
        listings     : '0'            # @model.listings()
        incomes      : '0'            # @model.incomes().sum()
        expenses     : '0'            # @model.expenses().sum()
        vacant_units : '0'            # @model.units().vacant().length
        # units        : '0'            # @model.units().length
      
      vars = _.merge(
        @model.toJSON(),
        details,
        unitsLength: if @model.unitsLength then @model.unitsLength else 0
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      )
      
      @$el.html JST["src/js/templates/property/summary.jst"](vars)
      @$("[rel=tooltip]").tooltip()
      @