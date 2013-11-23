define [
  "jquery"
  "underscore"
  "backbone"
  'collections/ListingList'
  'models/Listing'
  'views/helper/Alert'
  'views/listing/Summary'
  "i18n!nls/common"
  "i18n!nls/unit"
  "i18n!nls/listing"
  'templates/network/sub/listings'
], ($, _, Parse, ListingList, Listing, Alert, ListingView, i18nCommon, i18nUnit, i18nListing) ->

  class NetworkListingsView extends Parse.View
        
    initialize: (attrs) ->

      @editing = false
      
      @on "view:change", @clear

      @model.prep('listings')
      @model.prep('applicants')

      @listenTo @model.listings, "add", @addOne
      @listenTo @model.listings, "reset", @addAll

    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nListing: i18nListing
      @$el.html JST["src/js/templates/network/sub/listings.jst"](vars)
      
      @$list = @$("#listings tbody")

      # Fetch all the property items for this user
      if @model.listings.length is 0 then @model.listings.fetch() else @addAll()
      @
    

    addOne : (l) =>
      @$list.append (new ListingView(model: l)).render().el

    addAll : =>
      @$list.html ''
      if @model.listings.length > 0 
        @model.listings.each @addOne
      else
        @$list.html '<tr class="empty"><td colspan="4">' + i18nListing.listings.empty.network + '</td></tr>'