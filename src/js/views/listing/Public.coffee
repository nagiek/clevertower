define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/PhotoList"
  'models/Property'
  'models/Listing'
  'models/Inquiry'
  "views/helper/Alert"
  "views/photo/Public"
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/listing/public'
  "templates/helper/field/tenant"
  "datepicker"
], ($, _, Parse, moment, PhotoList, Property, Listing, Inquiry, Alert, PhotoView, i18nProperty, i18nListing, i18nGroup, i18nCommon) ->

  class PublicListingView extends Parse.View

    el: '#main'
    
    events:
      'click #show-modal': 'showModal'
      'submit form': 'apply'

      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'

    initialize: (attrs) ->

      @property = attrs.property
      @photos = new PhotoList [], property: @property

      @photos.bind "add", @addOne
      @photos.bind "reset", @addAll

      current = new Date().setYear(2014)

      @dates =
        start:  if @model.get "start_date"  then moment(@model.get("start_date")).format("L")  else moment(current).format("L")
        end:    if @model.get "end_date"    then moment(@model.get("end_date")).format("L")    else moment(current).add(1, 'year').subtract(1, 'day').format("L")

    render: ->
      vars =
        listing: @model.toJSON()
        posted: moment(@model.createdAt).fromNow()
        propertyId: @property.id
        property: @property.toJSON()
        publicUrl: @property.publicUrl()
        dates: @dates
        cover: @property.cover('span9')
        i18nProperty: i18nProperty
        i18nListing: i18nListing
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
      
      @$el.html JST["src/js/templates/listing/public.jst"](vars)
      @$list = $("#photos")

      @$startDate = @$('.start-date')
      @$endDate = @$('.end-date')
      $('.datepicker').datepicker()

      @photos.fetch()

      @

    addOne : (photo) =>
      view = new PhotoView(model: photo)
      @$list.append view.render().el
      
    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless @photos.length is 0
        @photos.each @addOne
      else
        @$list.before '<p class="empty">' + i18nProperty.empty.photos + '</p>'


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

    showModal: ->
      unless @inquiry
        @inquiry = new Inquiry listing: @model
        @inquiry.on 'invalid', (error) =>
          console.log error
          @$('.error').removeClass('error')
          @$('button.save').removeProp "disabled"

          msg = if i18nListing.errors[error.message]
                  i18nListing.errors[error.message]
                else i18nCommon.errors.unknown
              
          new Alert(event: 'model-save', fade: false, message: msg, type: 'error')
          switch error.message
            when 'unit_missing'
              @$('.unit-group').addClass('error')
            when 'dates_missing' or 'dates_incorrect'
              @$('.date-group').addClass('error')
      
      @on "save:success", (model) =>
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        @$('#apply-modal').modal('hide')

      @$('#apply-modal').modal()

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
        @inquiry.trigger "invalid", {message: 'tenants_incorrect'}
      else
        @inquiry.save attrs,
        success: (model) => 
          @trigger "save:success", model, this
        error: (model, error) => 
          @inquiry.trigger "invalid", error
        