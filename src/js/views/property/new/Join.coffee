define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  "views/helper/Alert"
  'views/lease/New'
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
    # Last two are needed if the user is a tenant.
  'templates/property/new/join'
  'templates/lease/form'
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
], ($, _, Parse, Lease, Alert, NewLeaseView, i18nProperty, i18nUnit, i18nLease, i18nCommon) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class JoinPropertyView extends NewLeaseView

    el: undefined
    tagName : "form"
    className: "join-form col-xs-12 col-md-offset-1 col-md-10"

    initialize: (attrs) ->
      
      delete @events["submit form"]

      @property = attrs.property
      @wizard = attrs.wizard
      @listenTo @wizard, "wizard:cancel wizard:finish", @clear

      # Don't set the property on the lease, as we may not have access to it.
      @model = new Lease(forNetwork: false)
            
      @listenTo @model, 'invalid', (error) =>

        console.log error
        @wizard.trigger("invalid")

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
            
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
        switch error.message
          when 'unit_missing', 'no_title'
            @$('.unit-group').addClass('has-error')
          when 'dates_missing', 'dates_incorrect'
            @$('.date-group').addClass('has-error')
      
      @current = new Date().setDate(1)
      @dates =
        start:  if @model.get "start_date"  then moment(@model.get("start_date")).format("L")  else moment(@current).format("L")
        end:    if @model.get "end_date"    then moment(@model.get("end_date")).format("L")    else moment(@current).add(1, 'year').subtract(1, 'day').format("L")

        
    render : ->
      
      vars = 
        lease: _.defaults @model.attributes, Lease::defaults
        property: @property.attributes
        profile: @property.get("profile").toJSON()
        isNew: true
        propertyIsNew: @property.isNew()
        unit: false
        dates: @dates
        emails: ""
        i18nProperty: i18nProperty
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        i18nCommon: i18nCommon

      @$el.html JST['src/js/templates/property/new/join.jst'](vars)

      # @el = "form.lease-form"
      # @$el = $("#content form.lease-form")
      @$unitSelect = @$('.unit-select')
      @$unitSelect.append "<option class='new-unit-option' value='-1'>#{i18nUnit.constants.new_unit}</option>"

      # We will definitely be adding a new unit.
      @$unitSelect.val("-1").trigger("change")
      @$('.new-unit').show()
          
      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      @$('.datepicker').datepicker()

      @

    clear : =>
      @undelegateEvents()
      @remove()
      delete this