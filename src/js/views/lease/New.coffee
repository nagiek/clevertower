define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "gapi"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "models/Tenant"
  "views/helper/Alert"
  "views/helper/SelectEmail"
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "templates/lease/new"
  "templates/lease/new-modal"
  "templates/lease/form"
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, moment, gapi, Property, Unit, Lease, Tenant, Alert, SelectEmail, i18nCommon, i18nUnit, i18nLease) ->

  class NewLeaseView extends Parse.View
    
    el: '.content'
    
    events:
      'submit form'                 : 'save'
      'click .remove'               : 'kill'

      # Adjust the modal (don't need this)
      # 'click .close'                : 'close'
      "click .google-oauth"         : "googleOAuth"

      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'
      
      # 'change .start-date'          : 'adjustEndDate'
      'change .unit-select'         : 'showUnitIfNew'
    
    initialize : (attrs) ->

      @property = attrs.property
      # unitId = prepopulated choice for managers
      # unit = tenant's one and only unit.
      @unitId = attrs.unitId
      @unit = attrs.unit
      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork

      @model = new Lease unless @model
      @model.set "network", Parse.User.current().get("network") if @forNetwork and Parse.User.current() and Parse.User.current().get("network")
      @model.set "forNetwork", true

      @modal = attrs.modal
      @setElement '#apply-modal' if @modal

      @listenTo @model, 'invalid', (error) =>
        @$('button.save').button "reset"

        console.log error

        msg = if error.message.indexOf(":") > 0
            args = error.message.split ":"
            fn = args.pop()
            switch fn
              when "overlapping_dates"
                i18nLease.errors[fn]("#{@baseUrl}/leases/#{args[0]}")
              else
                i18nLease.errors[fn](args[0])
          else if i18nLease.errors[error.message]
            i18nLease.errors[error.message]
          else
            i18nCommon.errors.unknown
            
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
        switch error.message
          when 'unit_missing'
            @$('.unit-group').addClass('has-error')
          when 'dates_missing' or 'dates_incorrect'
            @$('.date-group').addClass('has-error')
      
      @on "save:success", (model, newUnit) =>
        if @property
          @property.leases.add @model
          if newUnit
            @model.get("unit").set "activeLease", @model
            @property.units.add @model.get("unit")
        else
          Parse.User.current().get("network").leases.add @model
          if newUnit
            @model.get("unit").set "activeLease", @model
            Parse.User.current().get("network").units.add @model.get("unit")

        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        @model.id = model.id

        if @forNetwork and Parse.User.current()
          new Parse.Query("Tenant").equalTo("lease", @model).include("profile").find()
          .then (objs) =>
            # Add tenants to the network collection, if it exists.
            if @property then @property.tenants.add objs else Parse.User.current().get("network").tenants.add objs
          
          Parse.history.navigate "#{@baseUrl}/leases/#{model.id}", true
          # require ["views/lease/Show"], (ShowLeaseView) =>
          #   # Alert the user and move on
          #   new ShowLeaseView(model: @model, property: @model.get("property"), forNetwork: @forNetwork, baseUrl: @baseUrl).render()
            
          #   @clear()

        else 
          vars = 
            lease: model
            unit: model.get "unit"
            property: model.get "property"

          Parse.User.current().set(vars)

          if @modal
            @$el.modal('hide')
            @clear()
          else
            Parse.history.navigate "/manage", true
                
      @listenTo @model, 'destroy', @clear
      
      # # We may on public page instead of network.
      unless @unit
        if @property
          @property.prep("units")
          @listenTo @property.units, "add", @addOne
          @listenTo @property.units, "reset", @addAll
        else 
          Parse.User.current().get("network").prep("units")
          @listenTo Parse.User.current().get("network").units, "add", @addOne
          @listenTo Parse.User.current().get("network").units, "reset", @addAll

              
      @current = new Date().setDate(1)
      @dates =
        start:  if @model.get "start_date"  then moment(@model.get("start_date")).format("L")  else moment(@current).format("L")
        end:    if @model.get "end_date"    then moment(@model.get("end_date")).format("L")    else moment(@current).add(1, 'year').subtract(1, 'day').format("L")

    render: =>

      tmpl = (if @model.isNew() then 'new' else 'sub/edit') + if @modal then "-modal" else ""
      template = "src/js/templates/lease/#{tmpl}.jst"
      cancel_path = @baseUrl + if !@model.isNew() and @forNetwork then "/leases/#{@model.id}" else ""

      vars =
        lease: _.defaults @model.attributes, Lease::defaults
        unit: if @unit then @unit.toJSON() else false
        dates: @dates
        cancel_path: cancel_path
        title: if @property then @property.get("profile").name() else false
        # units: @property.units
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        emails: if @model.get "emails" then @model.get "emails" else ""

      @$el.html JST[template](vars)
      
      # @el = "form.lease-form"
      # @$el = $("#content form.lease-form")
          
      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      @$('.datepicker').datepicker()
      
      @$unitSelect = @$('.unit-select')
      if @unit
        @addOne @unit
      else
        if @property
          if @property.units.select((u) => u.get("property").id is @property.id).length is 0 then @property.units.fetch() else @addAll()
        else
          if Parse.User.current().get("network").units.length is 0 then Parse.User.current().get("network").units.fetch() else @addAll()

      @

    addOne : (u) =>
      selected = if @unitId and @unitId is u.id then " selected='selected'"
      else if @model.get("unit") and @model.get("unit").id is u.id then " selected='selected'"
      else ""
      HTML = "<option value='#{u.id}'" + selected + ">#{u.get('title')}</option>"
      @$unitSelect.append HTML
      # @$unitSelect.children(':last').before HTML

    addAll : =>
      @$unitSelect.html "<option value=''>#{i18nCommon.form.select.select_value}</option>" # if @$unitSelect.children().length > 2

      if @property
        units = @property.units.select((u) => u.get("property").id is @property.id)
        _.each units, @addOne
        if @modal or units.length is 0 
          selected = ' selected="selected"' 
          @$('.new-unit').show()
        else selected = ""
        @$unitSelect.append "<option class='new-unit-option' value='-1'#{selected}>#{i18nUnit.constants.new_unit}</option>"
      else
        # Group by property.
        properties = Parse.User.current().get("network").units.groupBy (u) -> u.get("property").id
        _.each properties, (set, property) =>
          @$unitSelect.append "<optgroup label='#{Parse.User.current().get("network").properties.get(property).get('title')}'>"
          _.each set, @addOne
          @$unitSelect.append "<option class='new-unit-option' value='#{property}'>#{i18nUnit.constants.new_unit}</option>"
          @$unitSelect.append "</optgroup>"


    # Split into separate functions for other uses, such as joining.
    save : (e) =>
      e.preventDefault()      
      @$('button.save').button "loading"
      data = @$('form').serializeObject()
      @$('.has-error').removeClass('has-error')

      attrs = @model.scrub data.lease

      newUnit = false

      # Set unit
      if @unit
        attrs.unit = @unit
        attrs.unit.set unit.scrub(data.unit.attributes)
      else if data.unit and data.unit.id
        if @property
          if data.unit.id is "-1"
            unit = new Unit data.unit.attributes
            unit.set "property", @property
            newUnit = true
          else 
            unit = @property.units.get data.unit.id
        else 
          property = Parse.User.current().get("network").properties.get(data.unit.id)
          if property
            unit = new Unit data.unit.attributes
            unit.set "property", property
          else 
            unit = Parse.User.current().get("network").units.get data.unit.id
        attrs.unit = unit
      
      # Validate tenants (assignment done in Cloud)
      userValid = true
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        attrs.emails = []
        # _.each data.emails.split(","), (email) =>
        for email in data.emails.split(",")
          email = $.trim(email)
          # validate is a backwards function.
          userValid = unless Parse.User::validate(email: email) then true else false
          break unless userValid
          attrs.emails.push email
      
      unless userValid
        @$('.emails-group').addClass('has-error')
        @model.trigger "invalid", {message: 'tenants_incorrect'}
      else
        @model.save attrs,
        success: (model) => 
          @trigger "save:success", model, newUnit
        error: (model, error) => 
          @model.trigger "invalid", error
        

    showUnitIfNew : (e) =>
      className = @$("option:selected", this)[0].className
      # Use show() and hide(), because default input->display:inline-block overrides 'hide' class
      if className is "new-unit-option" then @$('.new-unit').show() else @$('.new-unit').hide()

    # adjustEndDate : ->
    #   console.log e
    #   start = moment(e.target.value)
    #   end = moment(@$endDate.val())
    #   diff = end.diff(start, 'days')
    #   @$endDate.val start.add(diff, 'days').format("L")

    setThisMonth : (e) =>
      e.preventDefault()
      @$startDate.val moment(@current).format("L")
      @$endDate.val moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
    setNextMonth : (e) =>
      e.preventDefault()
      @$startDate.val moment(@current).add(1, 'month').format("L")
      @$endDate.val moment(@current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L")
      
    setJulyJune : (e) =>
      e.preventDefault()
      @$startDate.val moment(@current).month(6).format("L")
      @$endDate.val moment(@current).month(6).add(1, 'year').subtract(1, 'day').format("L")

    googleOAuth : (e) =>
      e.preventDefault()
      new SelectEmail(view: @).render().el

    clear : ->
      @stopListening()
      @undelegateEvents()
      delete this

    kill : (e) =>
      e.preventDefault()
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        @model.destroy()
        Parse.history.navigate @baseUrl, true