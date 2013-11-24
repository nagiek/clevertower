define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/TenantList"
  "models/Activity"
  "models/Property"
  "models/Unit"
  "models/Listing"
  "models/Tenant"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/listing"
  "templates/listing/new"
  "templates/listing/form"
  "templates/helper/field/unit"
  "templates/helper/field/property"
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, moment, TenantList, Activity, Property, Unit, Listing, Tenant, Alert, i18nCommon, i18nUnit, i18nListing) ->

  class NewListingView extends Parse.View
    
    el: '.content'
    
    events:
      'submit form'                 : 'save'
      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'
      
      # 'change .start-date'          : 'adjustEndDate'
      'change .unit-select'         : 'showUnitIfNew'
    
    initialize : (attrs) ->

      @property = attrs.property

      # unitId = prepopulated choice for managers
      # unit = tenant's one and only unit.
      @unit = attrs.unit
      @unitId = attrs.unitId
      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork
      
      @model = new Listing(network: Parse.User.current().get("network")) unless @model
      @template = "src/js/templates/listing/#{if @model.isNew() then 'new' else 'sub/edit'}.jst"
      @cancel_path = @baseUrl + if !@model.isNew() and @forNetwork then "/listings/#{@model.id}" else ""
            
      @listenTo @model, 'invalid', (error) =>
        console.log error
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"

        msg = if error.message.indexOf(":") > 0
            args = error.message.split ":"
            fn = args.pop()
            switch fn
              when "overlapping_dates"
                i18nListing.errors[fn]("#{@baseUrl}/listings/#{args[0]}")
              else
                i18nListing.errors[fn](args[0])
          else if i18nListing.errors[error.message]
            i18nListing.errors[error.message]
          else
            i18nCommon.errors.unknown
            
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
        switch error.message
          when 'unit_missing'
            @$('.unit-group').addClass('error')
          when 'dates_missing' or 'dates_incorrect'
            @$('.date-group').addClass('error')
      
      @listenTo @model, 'destroy', @clear

      @on "save:success", (model) =>

        if @property
          @property.listings.add @model
          @property.units.add @model.get("unit") if newUnit
        else
          Parse.User.current().get("network").listings.add @model
          Parse.User.current().get("network").units.add @model.get("unit") if newUnit

        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'

        # Parse.Cloud.afterSave "Listing", (req) ->
        if model.get "public"

          # Create activity
          activity = new Activity
          modelJSON = model.toJSON()
          activityVars = 
            activity_type: "new_listing"
            public: true
            rent: modelJSON.rent
            center: modelJSON.center
            listing: model
            unit: modelJSON.unit
            property: modelJSON.property
            network: modelJSON.network
            title: modelJSON.title

          activity.save(activityVars).then (returnedActivity) ->
            model.save activity: returnedActivity
            Parse.User.current().activity.add returnedActivity

        # Add the tenants to the network
        user = Parse.User.current() 
        network = user.get("network") if user
        if user and network
          new Parse.Query("Tenant").equalTo("listing", model).include("profile").find()
          .then (objs) -> network.tenants.add objs
        
        Parse.history.navigate "#{@baseUrl}/listings/#{model.id}", true
        # require ["views/listing/Show"], (ShowListingView) =>
        #   # Alert the user and move on
        #   new ShowListingView(model: model, property: model.get("property")).render()
        #   Parse.history.navigate "#{@baseUrl}/listings/#{model.id}"
        #   @clear()
      
      # @unit = @model.get("unit")
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
      rand = Math.floor Math.random() * i18nListing.form.title_placeholders.length
      vars =
        listing: _.defaults(@model.attributes, Listing::defaults)
        unit: if @unit then @unit.toJSON() else false
        dates: @dates
        cancel_path: @cancel_path
        title_placeholder: i18nListing.form.title_placeholders[rand]
        moment: moment
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nListing: i18nListing

      @$el.html JST[@template](vars)
      
      # @el = "form.listing-form"
      # @$el = $("#content form.listing-form")
      @$unitSelect = @$('.unit-select')
          
      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      $('.datepicker').datepicker()
      
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
        _.each @property.units.select((u) => u.get("property").id is @property.id), @addOne
        @$unitSelect.append "<option class='new-unit-option' value='-1'>#{i18nUnit.constants.new_unit}</option>"
      else
        # Group by property.
        unitsByProperties = Parse.User.current().get("network").units.groupBy (u) -> u.get("property").id
        Parse.User.current().get("network").properties.each (property) =>
          @$unitSelect.append "<optgroup label='#{property.get('title')}'>"
          _.each unitsByProperties[property.id], @addOne if unitsByProperties[property.id]
          @$unitSelect.append "<option class='new-unit-option' value='#{property.id}'>#{i18nUnit.constants.new_unit}</option>"
          @$unitSelect.append "</optgroup>"
      

    save : (e) =>
      e.preventDefault() if e
      
      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')

      # Massage the Only-String data from serializeObject()
      data.listing.rent = 0 if data.listing.rent is '' or data.listing.rent is '0'
      data.listing.rent = Number data.listing.rent if data.listing.rent

      _.each ['start_date', 'end_date'], (attr) ->
        data.listing[attr] = moment(data.listing[attr], i18nCommon.dates.moment_format).toDate() unless data.listing[attr] is ''
        data.listing[attr] = new Date if typeof data.listing[attr] is 'string'
      
      attrs = data.listing
      newUnit = false

      # Set unit
      if data.unit and data.unit.id isnt ""
        if @property
          if data.unit.id is "-1"
            unit = new Unit data.unit.attributes
            unit.set "property", @property
            newUnit = true
          else 
            unit = @property.units.get data.unit.id
        else 
          property = Parse.User.current().get("network").properties.get data.unit.id
          # Check if the unit is set to a property, shortcut for "make a new unit"
          if property
            unit = new Unit data.unit.attributes
            unit.set "property", property
            attrs.property = property
          else 
            unit = Parse.User.current().get("network").units.get data.unit.id
            attrs.property = unit.get "property"
        attrs.unit = unit

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

    setThisMonth : =>
      @$startDate.val moment(@current).format("L")
      @$endDate.val moment(@current).add(1, 'year').subtract(1, 'day').format("L")
      
    setNextMonth : =>
      @$startDate.val moment(@current).add(1, 'month').format("L")
      @$endDate.val moment(@current).add(1, 'month').add(1, 'year').subtract(1, 'day').format("L")
      
    setJulyJune : =>
      @$startDate.val moment(@current).month(6).format("L")
      @$endDate.val moment(@current).month(6).add(1, 'year').subtract(1, 'day').format("L")

    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this