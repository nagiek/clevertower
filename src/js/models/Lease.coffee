define [
  'underscore'
  'backbone'
  "collections/tenant/TenantList"
  "models/Property"
  "models/Unit"
  "moment"
], (_, Parse, TenantList, Property, Unit, moment) ->

  Lease = Parse.Object.extend "Lease",
  
    className: "Lease"

    defaults:
      rent: 0
      keys: 0
      garage_remotes: 0
      parking_fee: 0
      security_deposit: 0
      parking_space: ""
      first_month_paid: false
      last_month_paid: false
      checks_received: false
      
      # Relations
      # These break the data browser
      # tenants_pending: new Parse.Relation()
      # tenants_invited: new Parse.Relation()
      # tenants_current: new Parse.Relation()
    
    initialize: ->
      _.bindAll this, 'isActive'
    
    isActive: ->
      sd = @get "start_date"
      ed = @get "end_date"
      return false unless sd and ed
      today = new Date
      return sd < today and today < ed
    
    validate: (attrs = {}, options = {}) ->
      # Check all attribute existence, as validate is called on set
      # and save, and may not have the attributes in question.
      if attrs.start_date and attrs.end_date 
        if attrs.start_date is '' or attrs.end_date is ''
          return message: 'dates_missing'
        if moment(attrs.start_date).isAfter(attrs.end_date)
          return message: 'dates_incorrect'
      if attrs.unit
        if attrs.unit.id is ''
          return message: 'unit_missing'
        else if attrs.unit.isNew() and attrs.unit.isValid()
          # Validate associated  attrs.unit.attributes
          return error if error = attrs.unit.validationError
      false

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      switch collectionName
        when "tenants" 
          @[collectionName] = new TenantList [], lease: @

      @[collectionName]