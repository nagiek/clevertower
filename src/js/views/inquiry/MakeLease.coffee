define [
  "underscore"
  "models/Lease"
  "views/lease/New"
  "i18n!nls/common"
  "i18n!nls/listing"
], (_, Lease, NewLeaseView, i18nCommon, i18nListing) ->

  class LeaseFromListingView extends NewLeaseView
    
    events:
      'submit form'                 : 'accept'

      'click .starting-this-month'  : 'setThisMonth'
      'click .starting-next-month'  : 'setNextMonth'
      'click .july-to-june'         : 'setJulyJune'
      
      # 'change .start-date'          : 'adjustEndDate'
      'change .unit-select'         : 'showUnitIfNew'
    
    initialize : (attrs) ->
      
      _.bind 'accept'

      @model.prep "applicants"
      # Get the emails of applicants within our inquiry
      emails = @model.applicants.chain().select((a) => a.get("inquiry").id is @model.id).map((a) -> a.get("profile").get("email"))._wrapped.join(", ")

      # Change from the inquiry model to the lease model
      lease = new Lease 
        network: Parse.User.current().get("network")
        property: @model.get("property")
        start_date: @model.get("start_date")
        end_date: @model.get("end_date")
        emails: emails
        unit: @model.get("unit")
        listing: @model.get("listing")
        inquiry: @model
      @model = lease

      super

      @cancel_path = "/properties/#{@property.id}/listings/#{@model.get("listing").id}"


    accept : (e) ->
      e.preventDefault()
      if confirm(i18nCommon.actions.confirm + " " + i18nListing.warnings.accept_instructions)
        @model.get("listing").save public: false, {patch: true}
        @model.get("inquiry").save chosen: true, {patch: true}
        @save()