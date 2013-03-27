define [
  "jquery", 
  "underscore", 
  "backbone", 
  'models/Property',
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/summary',
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertySummaryView extends Parse.View
  
    tagName: "li"
    className: "row"
  
    # The PropertyView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Property and a PropertyView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      
      # Convert to collections.
      @model.set 
        cover        : @model.cover('profile')

      @model.set 
        tasks        : '0'            # @model.tasks()
        incomes      : '0'            # @model.incomes().sum()
        expenses     : '0'            # @model.expenses().sum()
        vacant_units : '0'            # @model.units().vacant().length
        # units        : '0'            # @model.units().length

      
      @model.bind "change", @render

  
    # Re-render the contents of the property item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        unitsLength: if @model.unitsLength then @model.unitsLength else 0
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      )
      $(@el).html JST["src/js/templates/property/summary.jst"](vars)
      @input = @$(".edit")
      this