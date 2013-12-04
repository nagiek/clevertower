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
    id: => "listing-#{@model.id}"

    events:
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->
      
      @baseUrl = attrs.baseUrl
      @onProperty = if attrs.onProperty then true else false
      @onUnit = if attrs.onUnit then true else false

    # Re-render the contents of the Unit item.
    render: ->

      if Parse.User.current().get("network")
        property = Parse.User.current().get("network").properties.get(@model.get("property").id)
      
      if Parse.User.current().get("property") and !property
        property = Parse.User.current().get("property")

      unless property then @onProperty = false 
      else 
        propertyTitle = property.get("title")
        propertyUrl = property.url()

      vars = _.merge @model.toJSON(),
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