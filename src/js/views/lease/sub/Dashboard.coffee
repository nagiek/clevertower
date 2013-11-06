define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Property'
  'models/Lease'
  'models/Listing'
  'models/Inquiry'
  'views/listing/Summary'
  "i18n!nls/property"
  "i18n!nls/lease"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/lease/sub/dashboard'
], ($, _, Parse, moment, Property, Lease, Listing, Inquiry, ListingView, i18nProperty, i18nLease, i18nListing, i18nCommon, inflection) ->

  class LeaseDashboardView extends Parse.View

    el: '.content'
    
    initialize: (attrs) ->

      @baseUrl = attrs.baseUrl
      
      @model.prep('listings')
      @model.prep('inquiries')
      @model.prep('applicants')

      @listenTo @model.listings, "add", @addOne
      @listenTo @model.listings, "reset", @addAll
      
    # Re-render the contents of the property item.
    render: ->
      vars = _.merge @model.toJSON(),
        # Strings
        i18nProperty: i18nProperty
        i18nLease: i18nLease
        i18nListing: i18nListing
        i18nCommon: i18nCommon
        hasNetwork: Parse.User.current().get("network")
        baseUrl: @baseUrl
        isMgr: true
      
      @$el.html JST["src/js/templates/lease/sub/dashboard.jst"](vars)
      @$list = @$("table#listings tbody")

      if @model.applicants.length is 0 then @model.applicants.fetch()
      if @model.inquiries.length is 0 then @model.inquiries.fetch()
      if @model.listings.length is 0 then @model.listings.fetch() else @addAll()
      @
    
    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this


    # Our collection includes non-property specific tenants, so we must be vigilant
    addOne : (l) =>
      @$list.append (new ListingView(model: l, baseUrl: @baseUrl, onUnit: true)).render().el

    addAll : =>

      # Only select listings on our unit.
      visible = @model.listings.select (l) => l.get("unit") and l.get("unit").id is @model.get("unit").id
      if visible.length is 0 then @$list.html "<tr class='empty'><td colspan='5'>#{i18nListing.listings.empty.self}</td></tr>"
      else
        @$list.html ""
        _.each visible, @addOne