define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/unit/UnitList"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "templates/lease/new"
  "templates/lease/_form"
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
], ($, _, Parse, moment, UnitList, Property, Unit, Lease, Alert, i18nCommon, i18nUnit, i18nLease) ->

  class NewLeaseView extends Parse.View
    
    el: '#content'
    
    events:
      'click .save' : 'save'
    
    initialize : (attrs) ->
      @model = new Lease unless @model
      @property = attrs.property

      unless @property.units
        @units = new UnitList
        @units.query = new Parse.Query(Unit)
        @units.query.equalTo "network", Parse.User.current().get "network"
        @units.comparator = (unit) ->
          title = unit.get "title"
          char = title.charAt title.length - 1
          # Slice off the last digit if it is a letter and add it as a decimal
          if isNaN(char)
            Number(title.substr 0, title.length-1) + char.charCodeAt()/128
          else
            Number title
      else
        @units = @property.units
            
      @render()

      @$unitSelect = @$('.unit-select')
      @units.bind "add", @addToSelect
      @units.bind "reset", @addAll
      @units.fetch()

    addToSelect : (unit) =>
      # @$unitSelect = @$('.unit-select') if @$unitSelect.length is 0
      HTML = "<option value='#{unit.id}'>#{unit.get('title')}</option>"
      @$unitSelect.children(':last').before HTML

    addAll : =>
      if @$unitSelect.children().length > 2
        @$unitSelect.html """
          <option value=''>#{i18nCommon.form.select.select_value}</option>
          <option value='-1'>#{i18nUnit.constants.new_unit}</option>
        """
      @units.each @addToSelect

    save : ->
      @model.save @$el.serializeObject().property,
        success: (property) =>
          @trigger "property:save", property, this
        error: (property, error) =>
          @$el.find('.error').removeClass('error')
          new Alert(event: 'property-save', fade: false, message: i18nProperty.errors[error.message], type: 'error')
          switch error.message
            when 'title_missing'
              @$el.find('#property-title-group').addClass('error') # Add class to Control Group
                
    render : ->
      vars = _.merge(
        lease: @model
        cancel_path: "/properties/#{@property.id}"
        units: @units
        moment: moment
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
      )
      console.log @$el
      @$el.html JST["src/js/templates/lease/new.jst"](vars)
      @