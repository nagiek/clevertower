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
      basedOnNetwork = user and network and @get("network").id is network.id

      @[collectionName] = switch collectionName
        when "inquiries"
          if basedOnNetwork then network.inquiries else new InquiryList [], property: @
        when "applicants"
          if basedOnNetwork then network.applicants else new ApplicantList [], property: @

      @[collectionName]

