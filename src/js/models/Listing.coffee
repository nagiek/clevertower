define [
  'underscore'
  'backbone'
  "collections/InquiryList"
  "collections/ApplicantList"
  "models/Property"
  "models/Unit"
  "moment"
], (_, Parse, InquiryList, ApplicantList, Property, Unit, moment) ->

  Listing = Parse.Object.extend "Listing",
  
    className: "Listing"

    defaults:
      title: ""
      public: true

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      user = Parse.User.current()
      network = user.get("network") if user
      @[collectionName] = switch collectionName
        when "applicants"
          unless user and network
            new ApplicantList [], listing: @
          else
            if network.applicants then network.applicants else new ApplicantList [], listing: @
        when "inquiries"
          unless user and network
            new InquiryList [], listing: @
          else
            if network.inquiries then network.inquiries else new InquiryList [], listing: @
      @[collectionName]