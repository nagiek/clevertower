define [
  "jquery"
  "underscore"
  "backbone"
  "collections/TenantList"
  "models/Property"
  "models/Lease"
  "models/Tenant"
  "models/Profile"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/lease"
  "templates/tenant/new"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, TenantList, Property, Lease, Tenant, Profile, Alert, i18nCommon, i18nLease) ->
  
  class NewTenantsView extends Parse.View
    
    el: '.content'
    
    events:
      'submit .tenants-form'          : 'save'
    
    initialize : (attrs) ->
      
      @property = attrs.property
      @baseUrl = attrs.baseUrl
      @leaseId = attrs.leaseId
      @forNetwork = attrs.forNetwork
      
      @leases = if @property then @property.prep('leases') else new LeaseList      
      @listenTo @leases, "add", @addOne
      @listenTo @leases, "reset", @addAll
      
      @on 'submit:return', ->
        @$('button.save').removeProp "disabled"
      
      @on 'submit:error', (error) ->
        @$('.emails-group').addClass('error') 
        new Alert(event: 'model-save', fade: false, message: i18nLease.errors[error.message], type: 'error')
          
      
      @on "submit:success", (model) =>
        @property.leases.add @model if !@leaseId
        new Parse.Query("Tenant").equalTo("lease", @model).include("profile").find()
        .then (objs) -> 
          @property.tenants.add objs
          # Add tenants to the network collection, if it exists.
          Parse.User.current().get("network").tenants.add objs if Parse.User.current().get("network")
        
        require ["views/lease/Show"], (ShowLeaseView) =>
          # Alert the user and move on
          new ShowLeaseView(model: @model, property: @property, forNetwork: @forNetwork, baseUrl: @baseUrl).render()
          Parse.history.navigate "#{@baseUrl}/leases/#{model.id}"
          @clear()

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

    save : (e) =>
      e.preventDefault()
      
      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')
      
      return @trigger "submit:error", {message: 'lease_missing'} unless data.lease
      
      attrs = 
        objectId: data.lease
        className: "Lease"
      
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
        @trigger "submit:return"
        @trigger "submit:error", {message: 'tenants_incorrect'}
      else
        Parse.Cloud.run "AddTenants", attrs,
        success: (model) =>
          @trigger "submit:return"
          @trigger "submit:success", model
        error: (model, error) =>
          @trigger "submit:return"
          @trigger "submit:error", message: 'tenants_incorrect'

    render: ->
      vars =
        baseUrl: @baseUrl
        cancelPath: @baseUrl + if @leaseId then "/leases/#{@leaseId}" else ""
        i18nCommon: i18nCommon
        i18nLease: i18nLease
      
      @$el.html JST["src/js/templates/tenant/new.jst"](vars)
      
      @$leaseSelect = @$('.lease-select')
      
      @leases.fetch() if @leases.length is 0
      @

    clear: =>
      @undelegateEvents()
      delete this