define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/tenant/TenantList"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "models/Tenant"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "templates/lease/new"
  "templates/lease/edit"
  "templates/lease/_form"
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, moment, TenantList, Property, Unit, Lease, Tenant, Alert, i18nCommon, i18nUnit, i18nLease) ->

  class NewLeaseView extends Parse.View
    
    el: '#content'
    
    events:
      'click .save'                 : 'save'
      'change .unit-select'         : 'showUnitIfNew'
      # 'change .start-date'          : 'adjustEndDate'
      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'
    
    initialize : (attrs) ->
      @model = new Lease unless @model
      @model.tenants = new TenantList unless @model.tenants
      
      @property = attrs.property
            
      @model.on 'invalid', (error) =>
        @$el.find('.error').removeClass('error')
        new Alert(event: 'model-save', fade: false, message: i18nLease.errors[error.message], type: 'error')
        switch error.message
          when 'unit_missing'
            @$('.unit-group').addClass('error')
          when 'dates_missing' or 'dates_incorrect'
            @$('.date-group').addClass('error')
      
      @on "save:success", (model) =>
        # Save the tenants, now that we have an ID
        @model.tenants.createQuery(model)
        @model.tenants.each (t) ->
          t.save()
        
        # Alert the user and move on
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
        Parse.history.navigate "/properties/#{@property.id}/leases/#{model.id}"
        @remove()
        @undelegateEvents()
        delete this
                
      @model.on 'destroy', =>
        @remove()
        @undelegateEvents()
        delete this
      
      if @property
        @property.loadUnits()
        @units = @property.units
              
      @current = new Date().setDate(1)
      @dates =
        start:  if @model.get "start_date"  then moment(@model.get("start_date")).format("L")  else moment(@current).format("L")
        end:    if @model.get "end_date"    then moment(@model.get("end_date")).format("L")    else moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
      @render()
      
      # @el = "form.lease-form"
      # @$el = $("#content form.lease-form")
      @$unitSelect = @$('.unit-select')
          
      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      $('.datepicker').datepicker()
          
      @units.bind "add", @addToSelect
      @units.bind "reset", @addAll
      @units.fetch()

    addToSelect : (u) =>
      HTML = "<option value='#{u.id}'" + (if @model.get("unit") and @model.get("unit").id == u.id then "selected='selected'" else "") + ">#{u.get('title')}</option>"
      @$unitSelect.children(':first').after HTML
      # @$unitSelect.children(':last').before HTML

    addAll : =>
      if @$unitSelect.children().length > 2
        @$unitSelect.html """
          <option value=''>#{i18nCommon.form.select.select_value}</option>
          <option value='-1'>#{i18nUnit.constants.new_unit}</option>
        """
      @units.each @addToSelect

    save : (e) =>
      e.preventDefault()
      data = @$('form').serializeObject()
      
      # Massage the Only-String data from serializeObject()
      _.each ['rent', 'keys', 'garage_remotes', 'security_deposit', 'parking_fee'], (attr) ->
        data.lease[attr] = 0 if data.lease[attr] is ''
        data.lease[attr] = Number data.lease[attr] if data.lease[attr] and isNaN data.lease[attr]

      _.each ['start_date', 'end_date'], (attr) ->
        data.lease[attr] = moment(data.lease[attr], i18nCommon.dates.moment_format).toDate() unless data.lease[attr] is ''
        data.lease[attr] = new Date if typeof data.lease[attr] is 'string'
      
      _.each ['checks_received', 'first_month_paid', 'last_month_paid'], (attr) ->
        data.lease[attr] = if data.lease[attr] isnt "" then true else false

      @model.set data.lease

      # Set unit
      if data.unit and data.unit.id isnt ""
        if data.unit.id is "-1"
          unit = new Unit data.unit.attributes
          unit.set "property", @property
        else 
          unit = @units.get data.unit.id
        @model.set "unit", unit

      # Validate tenants (setting comes after)
      userError = false
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        tenants = []
        _.each data.emails.split(","), (email) =>         
          account = new Parse.User(username: $.trim(email), email: $.trim(email))
          
          if account.isValid()
            console.log 'valid'
            tenants.push account
          else
            console.log 'invalid'
            userError = account.validationError
            

      if userError  
        new Alert(event: 'model-save', fade: false, message: i18nLease.errors.incorrect_tenants, type: 'error')
      else
        @model.save null,
          success: (model) => 
            @trigger "save:success", model, this
            @model.tenants.add tenants
          error: (model, error) => 
            @model.trigger "invalid", error
        

    showUnitIfNew : (e) =>
      if e.target.value is "-1" then @$('.new-unit').removeClass 'hide' else @$('.new-unit').addClass 'hide'

    # adjustEndDate : (e) =>
    #   console.log e
    #   start = moment(e.target.value)
    #   end = moment(@$endDate.val())
    #   diff = end.diff(start, 'days')
    #   @$endDate.val start.add(diff, 'days').format("L")

    setThisMonth : (e) =>
      e.preventDefault() if e
      @$startDate.val moment(@current).format("L")
      @$endDate.val moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
    setNextMonth : (e) =>
      e.preventDefault() if e
      @$startDate.val moment(@current).add(1, 'month').format("L")
      @$endDate.val moment(@current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L")
      
    setJulyJune : (e) =>
      e.preventDefault() if e
      @$startDate.val moment(@current).month(6).format("L")
      @$endDate.val moment(@current).month(6).add(1, 'year').subtract(1, 'day').format("L")

    render: ->
      vars = _.merge(
        lease: @model
        dates: @dates
        cancel_path: "/properties/#{@property.id}" + unless @model.isNew() then "/leases/#{@model.id}"
        # units: @units
        moment: moment
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
      )
      vars.unit = if @model.get "unit" then @model.get "unit" else false
      @$el.html JST["src/js/templates/lease/#{if @model.isNew() then 'new' else 'edit'}.jst"](vars)