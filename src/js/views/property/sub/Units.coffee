define [
  "jquery"
  "underscore"
  "backbone"
  'collections/unit/UnitList'
  'models/Property'
  'models/Unit'
  'views/unit/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/units'
], ($, _, Parse, UnitList, Property, Unit, UnitView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyUnitsView extends Parse.View
  
    el: "#content"
    
    events:
      'click #units-show a' : 'switchToShow'
      'click #units-edit a' : 'switchToEdit'
      'click #add-x'        : 'addX'
      'click .undo'         : 'undo'
      'click .save'         : 'save'
    
    initialize: (attrs) ->
      
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease)
      @$el.html JST["src/js/templates/property/sub/units.jst"](vars)
      
      @editing = false
      
      @$messages  = $("#messages")
      @$table     = @$("#units-table")
      @$list      = @$("#units-table tbody")
      @$actions   = @$(".form-actions")
      @$undo      = @$actions.find('.undo')
      
      # Create our collection of Properties
      @units = new UnitList(property: @model)
      
      # Setup the query for the collection to look for properties from the current user
      @units.query = new Parse.Query(Unit)
      @units.query.equalTo "property", @model
      @units.comparator = (unit) ->
        Number unit.get "title"
      @units.bind "add", @addOne
      @units.bind "reset", @addAll
      
      # Fetch all the property items for this user
      @units.fetch()
        # success: (collection, response, options) =>
        #   @units.add [{property: @model}] if collection.length is 0
                
    # Re-render the contents of the property item.
    render: =>
      @$list.html ""
      @$list.html '<p class="empty">' + i18nUnit.collection.empty + '</p>' if @units.length is 0
      
    switchToShow: (e) =>
      e.preventDefault()
      return unless @editing
      @$('ul.nav').children().removeClass('active')
      e.currentTarget.parentNode.className = 'active'
      @$table.find('.view-specific').toggleClass('hide')
      # @$table.find('.view-occupancy').show()
      @$actions.toggleClass('hide')
      @editing = false
      e
      
    switchToEdit: (e) =>
      e.preventDefault()
      return if @editing
      @$('ul.nav').children().removeClass('active')
      e.currentTarget.parentNode.className = 'active'
      @$table.find('.view-specific').toggleClass('hide')
      # @$table.find('.view-specific').show()
      @$actions.toggleClass('hide')
      @editing = true
      e

    # Add all items in the Units collection at once.
    addAll: (collection, filter) =>
      @render()
      @units.each @addOne

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
        if @units.length is 0
          unit = new Unit property: @model
        else
          unit = @units.at(@units.length - 1).clone()
          title = unit.get('title')
          
          newTitle = title.substr 0, title.length-1
          char = title.charAt title.length - 1
          # Convert to string for Parse DB
          newChar = if isNaN(char) then String.fromCharCode char.charCodeAt() + 1 else String Number(char) + 1
          unit.set 'title', newTitle + newChar
        @units.add unit
        x--

      @$undo.removeProp 'disabled'
      @$list.last().find('.title-group input').focus()
      
    undo: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?

      until x <= 0
        unless @units.length is 0
          # @units.pop() doesn't exist.
          @units.last().destroy() if @units.last().isNew()
        x--

      @$undo.prop 'disabled', 'disabled'
    
    save: (e) =>
      e.preventDefault()
      @units.each (unit) =>
        if unit.changed
          error = unit.validate(unit.attributes)
          unless error
            unit.save null,
              success: (unit) =>
                unless @$messages.hasClass 'alert-error'
                  @$messages
                  .addClass('alert-success')
                  .show()
                  .html(i18nCommon.actions.changes_saved)
                  .delay(3000)
                  .fadeOut()
                unit.trigger "save:success" if unit.changed
              error: (unit, error) =>
                unit.trigger "invalid", unit, error
          else
            unit.trigger "invalid", unit, error

    # handleError: (error) =>
    #   console.log error
    #   # Mark up form
    #   @$('.error').removeClass('error')
    #   switch error.message
    #     when 'title_missing'
    #       @$('#unit-' + unit.get "id").find('.title-group').addClass('error') # Add class to Control Group
    # 
    #   # Flash message
    #   @$messages.addClass('alert-error').show().html(i18nCommon.errors[error.message]).delay(3000).fadeOut().children().removeClass('alert-error')