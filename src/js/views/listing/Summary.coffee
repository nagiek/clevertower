define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Unit'
  'models/Listing'
  'views/helper/Alert'
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/common"
  'templates/listing/summary'
], ($, _, Parse, moment, Unit, Listing, Alert, i18nListing, i18nUnit, i18nCommon) ->

  class ListingSummaryView extends Parse.View
  
    #... is a table row.
    tagName: "tr"

    events:
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->
      
      @baseUrl = attrs.baseUrl
      @onProperty = if attrs.onProperty then true else false
      @onUnit = if attrs.onUnit then true else false

      @model.prep('inquiries')
          
      @listenTo @model, "save:success", @render
      @listenTo @model, "destroy", @clear
      
      @listenTo @model, "invalid", (unit, error) =>
        # Mark up form
        @$el.addClass('error')
        switch error.message
          when 'title_missing'
            @$('.title-group .control-group').addClass('error')

        msg = if error.code then i18nCommon.errors[error.message] else i18nUnit.errors[error.message]
        new Alert event: 'unit-invalid', fade: false, message: msg, type: 'danger'

    # Re-render the contents of the Unit item.
    render: ->
      inquiries = @model.inquiries.select (i) => i.get("listing").id is @model.id
      lastLogin = Parse.User.current().get("lastLogin") || Parse.User.current().updatedAt

      if Parse.User.current().get("network")
        property = Parse.User.current().get("network").properties.get(@model.get("property").id)
      
      if Parse.User.current().get("property") and !property
        property = Parse.User.current().get("property")

      unless property then @onProperty = false 
      else 
        propertyTitle = property.get("title")
        propertyUrl = property.url()

      vars = _.merge @model.toJSON(),
        count: inquiries.length
        newInquiries: _.select(inquiries, (i) -> i.createdAt > lastLogin).length
        start_date: moment(@model.get "start_date").format("LL")
        end_date: moment(@model.get "end_date").format("LL")
        status: i18nListing.fields.public[Number @model.get("public")]
        link_text: if @onUnit then i18nCommon.nouns.link else i18nCommon.classes.listing
        baseUrl: @baseUrl
        onProperty: @onProperty
        propertyTitle: propertyTitle
        propertyUrl: propertyUrl
        onUnit: @onUnit
        unitId: @model.get("unit").id
        unitTitle: @model.get("unit").get("title")
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/listing/summary.jst"](vars)
      @

    kill : (e) ->
      e.preventDefault()
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        id = @model.get("property").id
        @model.destroy()

    clear : =>
      @remove()
      @undelegateEvents()
      delete this