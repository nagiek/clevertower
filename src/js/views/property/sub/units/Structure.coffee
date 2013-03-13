define [
  "jquery"
  "underscore"
  "backbone"
  'collections/unit/UnitList'
  'models/Property'
  'models/Unit'
  'views/unit/Edit'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/units'
], ($, _, Parse, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyUnitsView extends Parse.View
  
    el: "#content"
    
    events:
      'click #add-x' : 'addX'
      'click .save'  : 'save'
    
    initialize: (attrs) ->
      
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease)
      @$el.html JST["src/js/templates/property/sub/units.jst"](vars)
      
      @messages = $("#messages")
      @$list = @$el.find("#units-form tbody")
      
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
      @units.fetch 
        success: (collection, response, options) =>
          @units.add [{property: @model}] if collection.length is 0
          
      @render()
                
    # Re-render the contents of the property item.
    render: =>
      @$list.html ""
      unless @units.length is 0
        @units.each @addOne
      else
        @$list.html '<p class="empty">' + i18nUnit.collection.empty + '</p>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (unit) =>
      view = new UnitView(model: unit)
      @$list.append view.render().el
        
    # Add a single todo item to the list by creating a view for it, and
    addX: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      inc = Number $('#increment').val()
      x = 1 unless x?
      
      until x <= 0
        unit = if @units.length is 0 then {title: title, property: @model} else @units.at(@units.length - 1).clone()
        title = Number unit.get('title')
        unit.set 'title', title + inc if _.isNumber(title)
        @units.add unit
        x--
    
    save: (e) =>
      e.preventDefault()
      @units.each (unit) =>
        unit.save null,
          success: =>
            
          error: =>
            @messages.addClass('alert-error').show().html(i18nCommon.form.erros.changes_saved).delay(3000).fadeOut().children().removeClass('alert-error')
            return
            
      @messages.addClass('alert-success').show().html(i18nCommon.actions.changes_saved).delay(3000).fadeOut().children().removeClass('alert-success')

