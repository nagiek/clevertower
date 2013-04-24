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
  
    el: ".content"
        
    initialize: (attrs) ->
      @editing = false
      
      _.bindAll this, 'render', 'addAll', 'addOne'

      @on "view:change", @clear

      @model.prep('listings')
      @model.prep('applicants')

      @model.listings.on "add", @addOne
      @model.listings.on "reset", @addAll

      @render()

    render: ->
      vars = 
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nListing: i18nListing
      @$el.html JST["src/js/templates/network/sub/listings.jst"](vars)
      
      @$list = @$("#listings-table tbody")

      # Fetch all the property items for this user
      if @model.listings.length is 0 then @model.listings.fetch() else @addAll()
      @
    

    addOne : (l) ->
      console.log (new ListingView(model: l)).render().el
      @$list.append (new ListingView(model: l)).render().el

    addAll : ->
      @$list.html ''
      if @model.listings.length > 0 
        @$("tr.empty").remove()
        @model.listings.each @addOne