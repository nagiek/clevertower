define [
  "jquery"
  "underscore"
  "backbone"
  'collections/UnitList'
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

      @baseUrl = attrs.baseUrl
      @isMgr = Parse.User.current().get("network") and Parse.User.current().get("network").id is @model.get("network").id 
      
      # Fetch all the property items for this user
      @listenTo @model.units, "add", @addOne
      @listenTo @model.units, "reset", @addAll

      @listenTo @model.units, "invalid", (error) =>
        console.log error
        @$('button.save').button "reset"
        msg = if error.code? i18nCommon.errors[error.message] else i18nUnit.errors[error.message]
        new Alert event: 'unit-invalid', fade: false, message: msg, type: 'danger'

      @listenTo @model.units, "save:success", =>
        @$('button.save').button "reset"
        new Alert event: 'units-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'

      @editing = false
                
    # Re-render the contents of the property item.
    render: =>
      today = moment(new Date).format('L')
      vars = 
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        today: today
        isMgr: @isMgr
        baseUrl: @baseUrl

      @$el.html JST["src/js/templates/property/sub/units.jst"](vars)      
      
      @$table     = @$("#units-table")
      @$undo      = @$('.undo')

      if @model.units.length is 0 then @model.units.fetch() else @addAll()
      @
    
    clear: (e) =>
      @undelegateEvents()
      delete this
    
    switchMode: (e) =>
      e.preventDefault()
      @$('#units-edit').toggleClass('active')
      @$table.find('.view-specific').toggleClass('hide')
      @editing = if @editing then false else true

    switchToShow: (e) => @switchMode if @editing  
    switchToEdit: (e) => @switchMode unless @editing

    # Add all items in the Units collection at once.
    addAll: (collection, filter) =>
      # Define @$list here, as we may 
      @$list = @$("#units-table > tbody")
      @$list.html ''

      visible = @model.units.select (u) => u.get("property").id is @model.id
      if visible.length > 0 then _.each visible, @addOne
      else
        @model.units.prepopulate(@model)
        @switchToEdit()
      # else @$list.html '<tr class="empty"><td colspan="8">' + i18nProperty.empty.units + '</td></tr>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (unit) =>
      @$list.find('tr.empty').remove()
      view = new UnitView(model: unit, view: @)
      @$list.append view.render().el
      view.$('.view-specific').toggleClass('hide') if @editing
      @$list.last().find('.title').focus()

    addX: (e) =>
      e.preventDefault()
      x = Number @$('#x').val()
      x = 1 unless x?

      until x <= 0
        @model.units.prepopulate(@model)
        x--

      @$undo.removeClass 'disabled'
      @$undo.removeProp 'disabled'
      @$list.last().find('.title').focus()
      
    undo: (e) =>
      e.preventDefault()
      x = Number @$('#x').val()
      x = 1 unless x

      while x > 0 and @model.units.last().isNew() and @model.units.length > 0 
        @model.units.last().destroy()
        x--

      # @$undo.button 'reset'
      # @$undo.prop 'disabled', 'disabled'
    
    save: (e) =>
      e.preventDefault()
      @$('.has-error').removeClass('has-error')
      @$('button.save').button "loading"
      Parse.Object.saveAll @model.units.models, 
        success: (units) => @model.units.trigger "save:success"
        error: (error) => @model.units.trigger "invalid", error
