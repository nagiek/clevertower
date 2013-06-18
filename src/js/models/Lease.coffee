define [
  'underscore'
  'backbone'
  "collections/TenantList"
  "collections/ListingList"
  "collections/InquiryList"
  "collections/ApplicantList"
  "models/Property"
  "models/Unit"
  "moment"
  "i18n!nls/common"
], (_, Parse, TenantList, ListingList, InquiryList, ApplicantList, Property, Unit, moment, i18nCommon) ->

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
    
    isActive: =>
      sd = @get "start_date"
      ed = @get "end_date"
      return false unless sd and ed
      today = new Date
      return sd < today and today < ed
    
    scrub: (lease) ->
      # Massage the Only-String data from serializeObject()
      for attr in ['rent', 'keys', 'garage_remotes', 'security_deposit', 'parking_fee']
        lease[attr] = 0 if lease[attr] is '' or lease[attr] is '0'
        lease[attr] = Number lease[attr] if lease[attr]

      for attr in ['start_date', 'end_date']
        lease[attr] = moment(lease[attr], i18nCommon.dates.moment_format).toDate() unless lease[attr] is ''
        lease[attr] = new Date if typeof lease[attr] is 'string'
      
      for attr in ['checks_received', 'first_month_paid', 'last_month_paid']
        lease[attr] = if lease[attr] isnt "" then true else false

      lease

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
          user = Parse.User.current()
          network = user.get("network") if user
          unless user and network
            @[collectionName] = new TenantList [], lease: @
          else
            @[collectionName] = if network.tenants then network.tenants else new TenantList [], lease: @
        when "listings"
          @[collectionName] = new ListingList [], lease: @
        when "inquiries"
          @[collectionName] = new InquiryList [], lease: @
        when "applicants"
          @[collectionName] = new ApplicantList [], lease: @

      @[collectionName]