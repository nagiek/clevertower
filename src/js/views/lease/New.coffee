define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "models/Tenant"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "templates/lease/new"
  "templates/lease/new-modal"
  "templates/lease/_form"
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, moment, Property, Unit, Lease, Tenant, Alert, i18nCommon, i18nUnit, i18nLease) ->

  class NewLeaseView extends Parse.View
    
    el: '.content'
    
    events:
      'submit form'                 : 'save'
      'click .close'                : 'close'

      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'
      
      # 'change .start-date'          : 'adjustEndDate'
      'change .unit-select'         : 'showUnitIfNew'
    
    initialize : (attrs) ->
      
      _.bindAll this, 'addOne', 'addAll', 'save', 'setThisMonth', 'setNextMonth', 'setJulyJune'

      @property = attrs.property

      @model = new Lease(network: Parse.User.current().get("network")) unless @model

      @setElement '#apply-modal' if attrs.modal

      tmpl = (if @model.isNew() then 'new' else 'edit') + if attrs.modal then "-modal" else ""
      @template = "src/js/templates/lease/#{tmpl}.jst"
      @cancel_path = "/properties/#{@property.id}" + unless @model.isNew() then "/leases/#{@model.id}" else ""
            
      @model.on 'invalid', (error) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"

        msg = if error.message.indexOf(":") > 0
            args = error.message.split ":"
            fn = args.pop()
            switch fn
              when "overlapping_dates"
                i18nLease.errors[fn]("/properties/#{@property.id}/leases/#{args[0]}")
              else
                i18nLease.errors[fn](args[0])
          else if i18nLease.errors[error.message]
            i18nLease.errors[error.message]
          else
            i18nCommon.errors.unknown
            
        new Alert(event: 'model-save', fade: false, message: msg, type: 'error')
        switch error.message
          when 'unit_missing'
            @$('.unit-group').addClass('error')
          when 'dates_missing' or 'dates_incorrect'
            @$('.date-group').addClass('error')
      
      @on "save:success", (model) =>

        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        @model.id = model.id

        # Add the tenants to the network
        user = Parse.User.current() 
        network = user.get("network") if user
        if user and network
          @property.leases.add @model
          new Parse.Query("Tenant").equalTo("lease", @model).include("profile").find()
          .then (objs) -> network.tenants.add objs
        
        require ["views/lease/Show"], (ShowLeaseView) =>
          # Alert the user and move on
          new ShowLeaseView(model: @model, property: @property).render()
          Parse.history.navigate "/properties/#{@property.id}/leases/#{model.id}"
          @undelegateEvents()
          delete this
                
      @model.on 'destroy', =>
        @undelegateEvents()
        delete this
      
      @units = @property.prep("units") if @property # We may on public page instead of network.

      @units.bind "add", @addOne
      @units.bind "reset", @addAll
              
      @current = new Date().setDate(1)
      @dates =
        start:  if @model.get "start_date"  then moment(@model.get("start_date")).format("L")  else moment(@current).format("L")
        end:    if @model.get "end_date"    then moment(@model.get("end_date")).format("L")    else moment(@current).add(1, 'year').subtract(1, 'day').format("L")

    addOne : (u) =>
      HTML = "<option value='#{u.id}'" + (if @model.get("unit") and @model.get("unit").id is u.id then "selected='selected'" else "") + ">#{u.get('title')}</option>"
      @$unitSelect.append HTML
      # @$unitSelect.children(':last').before HTML

    addAll : =>
      if @$unitSelect.children().length > 2
        @$unitSelect.html """
          <option value=''>#{i18nCommon.form.select.select_value}</option>
          <option value='-1'>#{i18nUnit.constants.new_unit}</option>
        """
      @units.each @addOne

    save : (e) ->
      e.preventDefault() if e
      
      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')
      
      # Massage the Only-String data from serializeObject()
      _.each ['rent', 'keys', 'garage_remotes', 'security_deposit', 'parking_fee'], (attr) ->
        data.lease[attr] = 0 if data.lease[attr] is '' or data.lease[attr] is '0'
        data.lease[attr] = Number data.lease[attr] if data.lease[attr]

      _.each ['start_date', 'end_date'], (attr) ->
        data.lease[attr] = moment(data.lease[attr], i18nCommon.dates.moment_format).toDate() unless data.lease[attr] is ''
        data.lease[attr] = new Date if typeof data.lease[attr] is 'string'
      
      _.each ['checks_received', 'first_month_paid', 'last_month_paid'], (attr) ->
        data.lease[attr] = if data.lease[attr] isnt "" then true else false

      attrs = data.lease

      # Set unit
      if data.unit and data.unit.id isnt ""
        if data.unit.id is "-1"
          unit = new Unit data.unit.attributes
          unit.set "property", @property
        else 
          unit = @units.get data.unit.id
        attrs.unit = unit
      
      # Validate tenants (assignment done in Cloud)
      userValid = true
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        attrs.emails = []
        _.each data.emails.split(","), (email) =>
          email = $.trim(email)
          # validate is a backwards function.
          userValid = unless Parse.User::validate(email: email) then true else false
          attrs.emails.push email if userValid
      
      unless userValid
        @$('.emails-group').addClass('error')
        @model.trigger "invalid", {message: 'tenants_incorrect'}
      else
        @model.save attrs,
        success: (model) => 
          @trigger "save:success", model, this
        error: (model, error) => 
          @model.trigger "invalid", error
        

    showUnitIfNew : (e) =>
      if e.target.value is "-1" then @$('.new-unit').removeClass 'hide' else @$('.new-unit').addClass 'hide'

    # adjustEndDate : ->
    #   console.log e
    #   start = moment(e.target.value)
    #   end = moment(@$endDate.val())
    #   diff = end.diff(start, 'days')
    #   @$endDate.val start.add(diff, 'days').format("L")

    setThisMonth : ->
      @$startDate.val moment(@current).format("L")
      @$endDate.val moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
    setNextMonth : ->
      @$startDate.val moment(@current).add(1, 'month').format("L")
      @$endDate.val moment(@current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L")
      
    setJulyJune : ->
      @$startDate.val moment(@current).month(6).format("L")
      @$endDate.val moment(@current).month(6).add(1, 'year').subtract(1, 'day').format("L")

    render: ->
      vars =
        lease: _.defaults @model.attributes, Lease::defaults
        unit: if @model.get "unit" then @model.get "unit" else false
        dates: @dates
        cancel_path: @cancel_path
        title: if @property then @property.get "title" else false
        # units: @units
        moment: moment
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        emails: if @model.get "emails" then @model.get "emails" else ""

      @$el.html JST[@template](vars)
      
      # @el = "form.lease-form"
      # @$el = $("#content form.lease-form")
      @$unitSelect = @$('.unit-select')
          
      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      $('.datepicker').datepicker()
      
      if @units.length is 0 then @units.fetch() else @addAll()

      @


    close : ->
      @undelegateEvents()
      delete this