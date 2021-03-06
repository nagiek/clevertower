define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Inquiry'
  'views/helper/Alert'
  'views/applicant/summary'
  "i18n!nls/listing"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/inquiry/summary'
], ($, _, Parse, moment, Inquiry, Alert, ApplicantView, i18nListing, i18nGroup, i18nCommon) ->

  class InquirySummaryView extends Parse.View
    
    tagName: "tr"

    events:
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->
        
      @listenTo @model, "destroy", @clear
      
      @model.prep('applicants')

      @listenTo @model.applicants, "add", @addOne
      @listenTo @model.applicants, "reset", @addAll

    clear: ->
      @remove()
      @undelegateEvents()
      delete this

    # Re-render the contents of the Unit item.
    render: =>
      vars =
        createdAt: moment(@model.createdAt).format("LL")
        comments: @model.get "comments"
        open: @model.get("listing").get("public")
        chosen: if @model.get("chosen") then true else false
        objectId: @model.id
        propertyId: @model.get("property").id
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/inquiry/summary.jst"](vars)

      @$list = @$('ul.applicants')
      if @model.applicants.length is 0 then @model.applicants.fetch() else @addAll()

      @

    # We may have the network tenant list. Therefore, we must
    # be sure that we are only displaying relevant users.
    addOne : (a) =>
      if a.get("inquiry").id is @model.id
        @$(".empty").remove()
        @$list.append (new ApplicantView(model: a)).render().el

    addAll : =>
      @$list.html ""
      @model.applicants.each((a) => @addOne(a) if a.get("inquiry").id is @model.id)

    kill : (e) =>
      e.preventDefault()
      @model.destroy()