define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "models/Applicant"
  "views/helper/Alert"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/inquiry/new'
  'templates/helper/field/tenant'
  'datepicker'
], ($, _, Parse, moment, Applicant, Alert, i18nListing, i18nCommon) ->

  class NewInquiryView extends Parse.View

    el: '#apply-modal'

    events:
      'submit form': 'apply'
      'click .close' : 'close'

    initialize: ->

      _.bindAll @, 'render', 'setThisMonth', 'setNextMonth', 'setJulyJune', 'apply'

      @model.on 'invalid', (error) =>
        console.log error
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"

        msg = if i18nListing.errors[error.message]
                i18nListing.errors[error.message]
              else i18nCommon.errors.unknown
            
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
        switch error.message
          when 'unit_missing'
            @$('.unit-group').addClass('error')
          when 'dates_missing' or 'dates_incorrect'
            @$('.date-group').addClass('error')
      
      @on "save:success", (model) =>
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        Parse.User.current().get("profile").applicants.create 
          profile: Parse.User.current().get("profile")
          inquiry: @model
          listing: @model.get "listing"
          property: @model.get "property"
          network: @model.get "network"
        @$el.modal('hide')

    render: ->
      vars =
        start_date: moment(@model.get("listing").get("start_date")).format("L")
        end_date: moment(@model.get("listing").get("end_date")).format("L")
        propertyTitle: @model.get("listing").collection.title
        i18nCommon: i18nCommon
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/inquiry/new.jst"](vars)

      @$('.datepicker').datepicker()
      @

    setThisMonth : (e) ->
      e.preventDefault()
      @$startDate.val moment(@current).format("L")
      @$endDate.val moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
    setNextMonth : (e) ->
      e.preventDefault()
      @$startDate.val moment(@current).add(1, 'month').format("L")
      @$endDate.val moment(@current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L")
      
    setJulyJune : (e) ->
      e.preventDefault()
      @$startDate.val moment(@current).month(6).format("L")
      @$endDate.val moment(@current).month(6).add(1, 'year').subtract(1, 'day').format("L")

    apply : (e) ->
      e.preventDefault()
      
      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')
      
      # Massage the Only-String data from serializeObject()      
      _.each ['start_date', 'end_date'], (attr) ->
        data.inquiry[attr] = moment(data.inquiry[attr], i18nCommon.dates.moment_format).toDate() unless data.inquiry[attr] is ''
        data.inquiry[attr] = new Date if typeof data.inquiry[attr] is 'string'

      attrs = data.inquiry
      
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
        
    close : ->
      @undelegateEvents()
      delete this