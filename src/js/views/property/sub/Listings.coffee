define [
  "jquery"
  "underscore"
  "backbone"
  'collections/ListingList'
  'models/Property'
  'models/Listing'
  'views/helper/Alert'
  'views/listing/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/listing"
  'templates/property/sub/listings'
], ($, _, Parse, ListingList, Property, Listing, Alert, ListingView, i18nCommon, i18nProperty, i18nListing) ->

  class PropertyListingsView extends Parse.View
  
    el: ".content"
        
    initialize: (attrs) ->
      @editing = false
      
      @baseUrl = attrs.baseUrl

      @on "view:change", @clear

      @model.prep('listings')
      @model.prep('applicants')

      @listenTo @model.listings, "add", @addOne
      @listenTo @model.listings, "reset", @addAll

    render: ->
      vars = 
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nListing: i18nListing
      @$el.html JST["src/js/templates/property/sub/listings.jst"](vars)
      
      @$list = @$("#listings-table tbody")

      # Fetch all the property items for this user
      if @model.listings.length is 0 then @model.listings.fetch() else @addAll()
      @
    
    # Our collection includes non-property specific tenants, so we must be vigilant
    addOne : (l) =>
      if l.get("property").id is @model.id
        @$("tr.empty").remove()
        @$list.append (new ListingView(model: l, baseUrl: @baseUrl)).render().el

    addAll : =>
      @$list.html ""
      visible = @model.listings.select (l) => l.get("property").id is @model.id
      if visible.length is 0 then @$list.html "<tr class='empty'><td colspan='5'>#{i18nListing.listings.empty.property}</td></tr>"
      else _.each visible, @addOne