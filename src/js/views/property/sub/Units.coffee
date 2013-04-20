define [
  "jquery"
  "underscore"
  "backbone"
  'collections/unit/UnitList'
  'models/Property'
  'models/Unit'
  'views/helper/Alert'
  'views/unit/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/units'
  'datepicker'
], ($, _, Parse, UnitList, Property, Unit, Alert, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyUnitsView extends Parse.View
  
    el: ".content"
    
    events:
      'click #units-edit' : 'switchMode'
      'click #add-x'      : 'addX'
      'click .undo'       : 'undo'
      'click .save'       : 'save'
    
    initialize: (attrs) ->
      
      @on "view:change", @clear
      
      # Fetch all the property items for this user
      @model.units.on "add", @addOne
      @model.units.on "reset", @addAll
      
      @editing = false
                
    # Re-render the contents of the property item.
    render: =>
      today = moment(new Date).format('L')
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease, today: today)

      @$el.html JST["src/js/templates/property/sub/units.jst"](vars)      
      
      @$table     = @$("#units-table")
      @$actions   = @$(".form-actions")
      @$undo      = @$actions.find('.undo')

      if @model.units.length is 0 
        @model.units.fetch()
        @switchToEdit()
      else
        @addAll()
      @
    
    clear: (e) =>
      @undelegateEvents()
      delete this
    
    switchMode: (e) =>
      e.preventDefault()
      @$('#units-edit').toggleClass('active')
      @$table.find('.view-specific').toggleClass('hide')
      @$actions.toggleClass('hide')
      @editing = if @editing then false else true

    switchToShow: (e) => @switchMode if @editing  
    switchToEdit: (e) => @switchMode unless @editing

    # Add all items in the Units collection at once.
    addAll: (collection, filter) =>
      # Define @$list here, as we may 
      @$list = @$("#units-table tbody")
      @$list.html ''
      if @model.units.length > 0 then @model.units.each @addOne
      else @$list.html '<p class="empty">' + i18nProperty.collection.empty.units + '</p>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (unit) =>
      @$('p.empty').hide()
      view = new UnitView(model: unit)
      @$list.append view.render().el
      view.$('.view-specific').toggleClass('hide') if @editing
      @$list.last().find('.title').focus()

    addX: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?

      until x <= 0
        @model.units.prepopulate()
        x--

      @$undo.removeProp 'disabled'
      @$list.last().find('.title').focus()
      
    undo: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?

      until x <= 0
        unless @model.units.length is 0
          # @model.units.pop() doesn't exist.
          @model.units.last().destroy() if @model.units.last().isNew()
        x--

      @$undo.prop 'disabled', 'disabled'
    
    save: (e) =>
      e.preventDefault()
      @$('.error').removeClass('error') if @$('.error')
      @model.units.each (unit) =>
        # if unit.changed
        unit.save null,
          success: (unit) =>
            new Alert(event: 'units-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
            unit.trigger "save:success" if unit.changed
          error: (unit, error) =>
            unit.trigger "invalid", unit, error
