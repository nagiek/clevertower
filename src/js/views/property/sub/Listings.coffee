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
  "plugins/toggler"
], ($, _, Parse, ListingList, Property, Listing, Alert, ListingView, i18nCommon, i18nProperty, i18nListing) ->

  class PropertyListingsView extends Parse.View
  
    el: ".content"

    events:
      "click .toggle input" : "save"
        
    initialize: (attrs) ->
      @editing = false
      
      @baseUrl = attrs.baseUrl

      @on "property:save", ->
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
      
      @listenTo @model, "invalid", (error) ->
        console.log error

      @model.prep('listings')
      @model.prep('inquiries')
      @model.prep('applicants')

      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

      @listenTo @model.inquiries, "add", @addOneInquiry
      @listenTo @model.inquiries, "reset", @addAllInquiries

    render: ->
      vars = 
        public:       @model.get("public")
        approx:       @model.get("approx")
        i18nProperty: i18nProperty
        i18nCommon:   i18nCommon
        i18nListing:  i18nListing
        baseUrl:      @baseUrl
      @$el.html JST["src/js/templates/property/sub/listings.jst"](vars)
      @$list = @$("#listings-table tbody")
      @$("[rel=popover]").popover(delay: show: 500, hide: 100)
      @$(".toggle").each -> $(this).toggler()

      # Fetch all the property items for this user
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
      if l.get("property").id is @model.id
        @$list.append (new ListingView(model: l, baseUrl: @baseUrl, onProperty: true)).render().el

    addAllListings : =>
      @$list.html ""
      visible = @model.listings.select (l) => l.get("property").id is @model.id
      if visible.length is 0 then @$list.html "<tr class='empty'><td colspan='5'>#{i18nListing.listings.empty.property}</td></tr>"
      else _.each visible, @addOneListing

    # Our collection includes non-property specific tenants, so we must be vigilant
    addOneInquiry : (l) =>
      if l.get("property").id is @model.id
        count = Number @$("#listing-#{l.get('inquiry').id} .inquiry-count")
        count++
        @$("#listing-#{l.get('inquiry').id} .inquiry-count").html count

    addAllInquiries : =>
      visible = @model.inquiries.select (i) => i.get("property").id is @model.id
      if visible.length > 0

        lastLogin = Parse.User.current().updatedAt
        countBy = _.countBy visible, (i) -> i.get("listing").id
        recent = _.select(visible, (i) -> i.createdAt > lastLogin)
        newCountBy = _.countBy(recent, (i) -> i.get("listing").id)

        # newCountBy = _.chain(visible).select((i) -> i.createdAt > lastLogin).countBy((i) -> i.id).value()
        _.each countBy, (count, id) =>
          @$("#listing-#{id} .inquiry-count").html(count)
        _.each newCountBy, (count, id) => 
          @$("#listing-#{id} .new-inquiry-count-wrapper").show().find(".new-inquiry-count").html(count)

    save : =>      
      attrs = @model.scrub @$('form').serializeObject().property

      @model.save attrs,
        success: (property) =>
          @trigger "property:save", property, this
        error: (property, error) =>
          @model.trigger "invalid", error, this