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

      @model.prep('listings')
      @model.prep('inquiries')
      @model.prep('applicants')

      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

      @listenTo @model.inquiries, "add", @addOneInquiry
      @listenTo @model.inquiries, "reset", @addAllInquiries

    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nListing: i18nListing
      @$el.html JST["src/js/templates/network/sub/listings.jst"](vars)
      
      @$list = @$("#listings tbody")

      # Make sure we get the listings first!
      if @model.listings.length is 0 
        @model.listings.query.find().then (objs) =>
          @model.listings.reset(objs)
          if @model.inquiries.length is 0 then @model.inquiries.fetch() else @addAllInquiries()
      else
        @addAllListings()
        if @model.inquiries.length is 0 then @model.inquiries.fetch() else @addAllInquiries()
      if @model.applicants.length is 0 then @model.applicants.fetch()
      @
    

    # Our collection includes non-property specific tenants, so we must be vigilant
    addOneListing : (l) =>
      @$list.append (new ListingView(model: l, baseUrl: @baseUrl, onProperty: true)).render().el

    addAllListings : =>
      @$list.html ""
      if @model.listings.length is 0 then @$list.html "<tr class='empty'><td colspan='4'>#{i18nListing.listings.empty.network}</td></tr>"
      else @model.listings.each @addOneListing

    # Our collection includes non-property specific tenants, so we must be vigilant
    addOneInquiry : (l) =>
      count = Number @$("#listing-#{l.get('inquiry').id} .inquiry-count")
      count++
      @$("#listing-#{l.get('inquiry').id} .inquiry-count").html count

    addAllInquiries : =>
      if @model.inquiries.length > 0

        lastLogin = Parse.User.current().get("lastLogin") || Parse.User.current().updatedAt
        countBy = @model.inquiries.countBy (i) -> i.get("listing").id
        recent = @model.inquiries.select (i) -> i.createdAt > lastLogin
        newCountBy = _.countBy(recent, (i) -> i.get("listing").id)

        # newCountBy = _.chain(visible).select((i) -> i.createdAt > lastLogin).countBy((i) -> i.id).value()
        _.each countBy, (count, id) =>
          @$("#listing-#{id} .inquiry-count").html(count)
        _.each newCountBy, (count, id) => 
          @$("#listing-#{id} .new-inquiry-count-wrapper").show().find(".new-inquiry-count").html(count)


    addOne : (l) =>
      @$list.append (new ListingView(model: l)).render().el

    addAll : =>
      @$list.html ''
      if @model.listings.length > 0 
        @model.listings.each @addOne
      else
        @$list.html '<tr class="empty"><td colspan="4">' + i18nListing.listings.empty.network + '</td></tr>'