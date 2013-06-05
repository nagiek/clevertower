define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/listing/publicsummary'
], ($, _, Parse, moment, i18nListing, i18nCommon) ->

  class ListingPublicSummaryView extends Parse.View
  
    #... is a table row.
    tagName: "tr"

    events:
      'click .show-modal': 'showModal'

    initialize : (attrs) ->
      if Parse.User.current()
        @markAsApplied()
      else 
        Parse.Dispatcher.on "user:login", @markAsApplied

    markAsApplied: ->
      Parse.User.current().get("profile").applicants.on "add", (model) => if model.id is @model.id then @render()

    # Re-render the contents of the Unit item.
    render: ->
      applied = if Parse.User.current() then Parse.User.current().get("profile").applicants.find (model) => model.get("listing").id is @model.id else false
      vars = 
        applied: applied
        rent: @model.get("rent")
        start_date: moment(@model.get("start_date")).format("LL")
        end_date: moment(@model.get("end_date")).format("LL")
        createdAt: moment(@model.createdAt).fromNow()
        i18nCommon: i18nCommon
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/listing/publicsummary.jst"](vars)
      @

    showModal: (e) =>
      e.preventDefault()
      if Parse.User.current()
        require ['models/inquiry', 'views/inquiry/new'], (Inquiry, InquiryView) =>
          @inquiry = new Inquiry listing: @model unless @inquiry
          new InquiryView(model: @inquiry).render().$el.modal()
      else
        $('#signup-modal').modal()