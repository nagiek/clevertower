define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/ApplicantList'
  'models/Unit'
  'models/Listing'
  'models/Tenant'
  'views/inquiry/Summary'
  'views/tenant/Summary'
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/listing/show'
], ($, _, Parse, moment, ApplicantList, Unit, Listing, Tenant, InquiryView, TenantView, i18nListing, i18nUnit, i18nProperty, i18nCommon) ->
  
  class ShowListingView extends Parse.View
    
    el: ".content"
    
    initialize: (attrs) =>
      @property = attrs.property
      
      @model.prep('inquiries')
      @model.prep('applicants')
      
      @model.inquiries.on "add",   @addOne
      @model.inquiries.on "reset", @addAll
      
    # Re-render the contents of the Unit item.
    render: ->

      topDomain = location.host.split(".")
      topDomain.shift()
      topDomain = '//' + topDomain.join(".")

      vars = _.merge @model.toJSON(),
        posted: moment(@model.createdAt).fromNow()
        topDomain: topDomain
        publicUrl: @property.publicUrl()
        propertyId: @property.id
        property: @property.toJSON()
        unitId: @model.get("unit").id
        unitTitle: @model.get("unit").get("title")
        start_date: moment(@model.get "start_date").format("LL")
        end_date: moment(@model.get "end_date").format("LL")
        i18nListing: i18nListing
        i18nUnit: i18nUnit
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      
      @$el.html JST["src/js/templates/listing/show.jst"](vars)
      
      @$list = @$('table#inquiries tbody')
      
      if @model.inquiries.length is 0 then @model.inquiries.fetch() else @addAll()
      @
      
    # We may have the network tenant list. Therefore, we must
    # be sure that we are only displaying relevant users.
    addOne : (l) =>
      if l.get("listing").id is @model.id
        @$(".empty").remove()
        @$list.append (new InquiryView(model: l)).render().el

    addAll : =>
      @$list.html ""
      visible = @model.inquiries.select (i) => i.get("listing").id is @model.id
      unless visible.length is 0
        _.each visible, @addOne
      else
        @$list.html '<tr class="empty"><td colspan="3">' + i18nListing.inquiries.empty.listing + '</td></tr>'