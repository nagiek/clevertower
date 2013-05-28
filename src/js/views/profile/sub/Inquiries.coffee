define [
  "jquery"
  "underscore"
  "backbone"
  "views/inquiry/own"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, InquiryView, i18nUser, i18nCommon) ->

  class ProfileInquiriesView extends Parse.View
  
    el: "#inquiries"
    
    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear

      @model.prep('applicants')
      @model.applicants.on "reset", @addAllInquiries

      @$inquiryList = @$("> ul")
    
    render: ->      
      if @model.applicants.length > 0 then @addAllInquiries else @model.applicants.fetch()
      @

    clear: ->
      @remove()
      @undelegateEvents()
      delete this

    # Inquiries
    # ---------

    addOneInquiry : (i) =>
      @$inquiryList.append (new InquiryView(model: i)).render().el

    addAllInquiries : =>
      @$inquiryList.html ""
      @printedInquiries = new Array
      unless @model.applicants.length is 0
        @$inquiryList.find(".empty").remove()

        # Reverse and group associations
        groupedApplicants = @model.applicants.groupBy (a) -> a.get("inquiry").id
        groupedInquiries = _.map groupedApplicants, (a) -> a[0].get("inquiry") # Take the first; they'll all be equal anyway.
        _.each(groupedInquiries, (i) -> i.applicants = groupedApplicants[i.id])

        # Organize by dates
        dates = _.groupBy(groupedInquiries, (i) -> moment(i.createdAt).format("LL"))
        _.each dates, (dateInquiries, date) =>
          @$inquiryList.append "<li class='nav-header'>#{date}</li>"
          _.each dateInquiries, @addOneInquiry
          @$inquiryList.append "<li class='divider'></li>"

      else 
        @$inquiryList.html '<li class="empty">' + i18nUser.empty.inquiries + '</li>'
      