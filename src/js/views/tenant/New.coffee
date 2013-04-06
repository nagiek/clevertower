define [
  "jquery"
  "underscore"
  "backbone"
  "collections/tenant/TenantList"
  "models/Property"
  "models/Lease"
  "models/Tenant"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/lease"
  "templates/tenant/new"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, TenantList, Property, Lease, Tenant, Alert, i18nCommon, i18nLease) ->
  
  class NewTenantsView extends Parse.View
    
    el: '.content'
    
    events:
      'submit .tenants-form'          : 'save'
    
    initialize : (attrs) ->
      
      _.bindAll this, 'addOne', 'addAll', 'save'
      
      @property = attrs.property
      @leaseId = attrs.leaseId
      
      @render()
      
      if @property
        @property.load('leases')
        @leases = @property.leases
      else 
        @leases = new LeaseList
        @leases.fetch()
      
      @leases.bind "add", @addOne
      @leases.bind "reset", @addAll
      
      @on 'submit:error', (error) ->
        @$('button.save').removeProp "disabled"
        @$('.emails-group').addClass('error') 
        new Alert(event: 'model-save', fade: false, message: error.message, type: 'error')
          
      @on 'submit:success', (lease) ->
        @$('button.save').removeProp "disabled"
        new Alert(event: 'model-save', message: i18nCommon.actions.changes_saved, type: 'success')
        Parse.history.navigate "/properties/#{@property.id}/leases/#{lease.id}"
      

      
      # @el = "form.lease-form"
      # @$el = $("#content form.lease-form")
          


    addOne : (l) =>
      if l.isActive() then @addActive(l) else @addInactive(l) 

    addActive : (l) =>
      title = l.get("unit").get('title')
      HTML = "<option value='#{l.id}'" + (if @leaseId and @leaseId is l.id then " selected='selected'") + ">#{title}</option>"

      @$leaseSelect.children('.group-active').append HTML
      # @$leaseSelect.children(':last').before HTML
      
    addInactive : (l) =>
      title = l.get("unit").get('title') + " (" + l.get("start_date") + " - " + l.get("end_date") + ")"
      HTML = "<option value='#{l.id}'" + (if @leaseId and @leaseId is l.id then " selected='selected'") + ">#{title}</option>"

      @$leaseSelect.children('.group-inactive').append HTML
      # @$leaseSelect.children(':last').before HTML

    addAll : =>
      if @$leaseSelect.children().length > 1
        @$leaseSelect.html """
        <option value=''>#{i18nCommon.form.select.select_value}</option>
        <optgroup class="group-active" label="#{i18nLease.dates.active}"></optgroup>
        <optgroup class="group-inactive" label="#{i18nLease.dates.inactive}"></optgroup>
        """
      _.each @leases.active(), @addActive
      _.each @leases.inactive(), @addInactive

    save : (e) ->
      e.preventDefault()
      
      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')
      
      return @trigger "submit:error", {message: 'lease_missing'} unless data.lease
      
      attrs = lease: data.lease
      
      # Validate tenants (assignment done in Cloud)
      userValid = true
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        attrs.emails = []
        _.each data.emails.split(","), (email) =>
          email = $.trim(email)
          # account will not be saved directly. We create one only for validation.
          account = new Parse.User(username: email, email: email)
          attrs.emails.push email if userValid = account.isValid()

      
      unless userValid
        @trigger "submit:error", {message: 'tenants_incorrect'}
      else
        Parse.Cloud.run "AddTenants", attrs,
        success: (model) => @trigger "submit:success", model
        error: (model, error) => @trigger "submit:error", {message: 'tenants_incorrect'}

    render: ->
      vars = _.merge(
        property_path: "/properties/#{@property.id}"
        cancel_path: "/properties/#{@property.id}" + if @leaseId then "/leases/#{@leaseId}"
        i18nCommon: i18nCommon
        i18nLease: i18nLease
      )
      @$el.html JST["src/js/templates/tenant/new.jst"](vars)
      
      @$leaseSelect = @$('.lease-select')