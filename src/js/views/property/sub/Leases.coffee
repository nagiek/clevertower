define [
  "jquery"
  "underscore"
  "backbone"
  'collections/lease/LeaseList'
  'models/Property'
  'models/Lease'
  'views/helper/Alert'
  'views/lease/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/leases'
], ($, _, Parse, LeaseList, Property, Lease, Alert, LeaseView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyLeasesView extends Parse.View
  
    el: ".content"
    
    events:
      'click #leases-show a'  : 'switchToShow'
      'click #leases-edit a'  : 'switchToEdit'
      'click #add-x'          : 'addX'
      'click .undo'           : 'undo'
      'click .save'           : 'save'
    
    initialize: (attrs) ->
      @editing = false
      
      @on "view:change", @clear
      
      @model.load('units')
      @model.load('leases')
      @model.leases.on "add", @addOne
      @model.leases.on "reset", @addAll

    render: =>
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease)
      @$el.html JST["src/js/templates/property/sub/leases.jst"](vars)
      
      @$table     = @$("#leases-table")
      @$list      = @$("#leases-table tbody")
      @$actions   = @$(".form-actions")
      @$undo      = @$actions.find('.undo')

      # Fetch all the property items for this user
      @model.leases.fetch()
      @

    
    clear: (e) =>
      @undelegateEvents()
      delete this
    
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

    # Add all items in the Leases collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      @model.leases.each @addOne
      @$list.html '<p class="empty">' + i18nLease.collection.empty.leases + '</p>' if @model.leases.length is 0

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (lease) =>
      @$('p.empty').hide()
      unitId = lease.get("unit").id
      
      title = @model.units.get(unitId).get("title")
      view = new LeaseView(model: lease, title: title)
      @$list.append view.render().el
      view.$el.find('.view-specific').toggleClass('hide') if @editing
      
    addX: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?
            
      until x <= 0
        if @model.leases.length is 0
          lease = new Lease property: @model
        else
          lease = @model.leases.at(@model.leases.length - 1).clone()
          title = lease.get('title')
          
          newTitle = title.substr 0, title.length-1
          char = title.charAt title.length - 1
          # Convert to string for Parse DB
          newChar = if isNaN(char) then String.fromCharCode char.charCodeAt() + 1 else String Number(char) + 1
          lease.set 'title', newTitle + newChar
        @model.leases.add lease
        x--

      @$undo.removeProp 'disabled'
      @$list.last().find('.title-group input').focus()
      
    undo: (e) =>
      e.preventDefault()
      x = Number $('#x').val()
      x = 1 unless x?

      until x <= 0
        unless @model.leases.length is 0
          # @model.leases.pop() doesn't exist.
          @model.leases.last().destroy() if @model.leases.last().isNew()
        x--

      @$undo.prop 'disabled', 'disabled'
    
    save: (e) =>
      e.preventDefault()
      @$('.error').removeClass('error') if @$('.error')
      @model.leases.each (lease) =>
        if lease.changed
          error = lease.validate(lease.attributes)
          unless error
            lease.save null,
              success: (lease) =>
                new Alert(event: 'leases-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
                lease.trigger "save:success" if lease.changed
              error: (lease, error) =>
                lease.trigger "invalid", lease, error
          else
            lease.trigger "invalid", lease, error

    # handleError: (error) =>
    #   console.log error
    #   # Mark up form
    #   @$('.error').removeClass('error')
    #   switch error.message
    #     when 'title_missing'
    #       @$('#lease-' + lease.get "id").find('.title-group').addClass('error') # Add class to Control Group
    # 
    #   # Flash message
    #   @$messages.addClass('alert-error').show().html(i18nCommon.errors[error.message]).delay(3000).fadeOut().children().removeClass('alert-error')