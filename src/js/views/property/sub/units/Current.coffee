define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/unit/UnitList'
  'models/Property'
  'models/Unit'
  'views/unit/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/current'
], ($, _, Parse, moment, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyCurrentView extends Parse.View
  
    el: "#content"
    
    initialize: (attrs) ->
      
      vars = _.merge(
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
      )
      @$el.html JST["src/js/templates/property/sub/current.jst"](vars)
      
      @$list = @$el.find("#current-units tbody")
      
      # Create our collection of Properties
      @units = new UnitList(property: @model)
      
      # Setup the query for the collection to look for properties from the current user
      @units.query = new Parse.Query(Unit)
      @units.query.equalTo "property", @model
      @units.comparator = (unit) ->
        unit.get "title"
      @units.bind "add", @addOne
      @units.bind "reset", @render
    
      # Fetch all the property items for this user
      @units.fetch()
      
      @render()
      
    # Re-render the contents of the property item.
    render: =>
      @$list.html ""
      unless @units.length is 0
        @units.each @addOne
        @$list.children(':even').addClass 'views-row-even'
        @$list.children(':odd').addClass  'views-row-odd'
      else
        @$list.html '<p class="empty">' + i18nUnit.collection.empty + '</p>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (unit) =>
      view = new UnitView(model: unit)
      @$list.append view.render().el
