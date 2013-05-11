define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Lease'
  'models/Unit'
  'models/Inquiry'
  'views/helper/Alert'
  'views/applicant/summary'
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/inquiry/own'
], ($, _, Parse, moment, Lease, Unit, Inquiry, Alert, ApplicantView, i18nListing, i18nCommon) ->

  class OwnInquiryView extends Parse.View
    
    tagName: "li"

    events:
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->

      _.bindAll @, 'render', 'kill', 'addOne', 'addAll'
        
      @model.on "destroy", =>
        @remove()
        @undelegateEvents()
        delete this

    # Re-render the contents of the Unit item.
    render: ->

      status_raw = if @model.get("listing").get("public") then 'open' else if @model.get("chosen") then 'chosen' else 'closed'

      status = switch status_raw
        when 'open' then i18nCommon.adjectives.open
        when 'chosen' then i18nListing.inquiries.chosen
        when 'closed' then i18nCommon.adjectives.closed

      label = switch status_raw
        when 'open' then ' label-info'
        when 'chosen' then ' label-success'
        when 'closed' then ''

      vars =
        label: label
        status: status
        objectId: @model.id
        propertyId: @model.get("property").id
        propertyTitle: @model.get("property").get("title")
        publicUrl: @model.get("property").publicUrl()
        i18nCommon: i18nCommon
        i18nListing: i18nListing
      $(@el).html JST["src/js/templates/inquiry/own.jst"](vars)

      @$list = @$('ul.applicants')
      @addAll()

      @


    addOne : (a) =>
      @$(".empty").remove()
      @$list.append (new ApplicantView(model: a)).render().el

    addAll : =>
      @$list.html ""
      _.each @model.applicants, @addOne

    kill : (e) ->
      e.preventDefault()
      @model.destroy() if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)