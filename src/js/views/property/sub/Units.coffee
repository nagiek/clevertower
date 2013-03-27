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
  
    el: "#content"
    
    events:
      'click #units-edit' : 'switchView'
      'click #add-x'      : 'addX'
      'click .undo'       : 'undo'
      'click .save'       : 'save'
    
    initialize: (attrs) ->
      
      today = moment(new Date).format('L')
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease, today: today)
      @$el.html JST["src/js/templates/property/sub/units.jst"](vars)
      
      @editing = false
      
      @$messages  = $("#messages")
      @$table     = @$("#units-table")
      @$list      = @$("#units-table tbody")
      @$actions   = @$(".form-actions")
      @$undo      = @$actions.find('.undo')
      
      @model.loadUnits()

      @model.units.on "add", @addOne
      @model.units.on "reset", @addAll
      
      # Fetch all the property items for this user
      @model.units.fetch()
      
        # success: (collection, response, options) =>
        #   @model.units.add [{property: @model}] if collection.length is 0
                
    # Re-render the contents of the property item.
    render: =>
      @$list.html ""
      @$list.html '<p class="empty">' + i18nUnit.collection.empty + '</p>' if @model.units.length is 0
    
    switchView: (e) =>
      e.preventDefault()
      @$table.find('.view-specific').toggleClass('hide')
      @$actions.toggleClass('hide')
      @editing = if @editing then false else true

    # switchToShow: (e) =>      
    # switchToEdit: (e) =>


    # Add all items in the Units collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      @render()
      @model.units.each @addOne

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (unit) =>
      @$('p.empty').hide()
      view = new UnitView(model: unit)
      @$list.append view.render().el
      view.$el.find('.view-specific').toggleClass('hide') if @editing
      
    addX: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?
            
      until x <= 0
        if @model.units.length is 0
          unit = new Unit property: @model
        else
          unit = @model.units.at(@model.units.length - 1).clone()

          unit.set "has_lease", false
          unit.unset "activeLease"

          title = unit.get 'title'
          newTitle = title.substr 0, title.length-1
          char = title.charAt title.length - 1
          # Convert to string for Parse DB
          newChar = if isNaN(char) then String.fromCharCode char.charCodeAt() + 1 else String Number(char) + 1
          unit.set 'title', newTitle + newChar
        @model.units.add unit
        x--

      @$undo.removeProp 'disabled'
      @$list.last().find('.title-group input').focus()
      
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
