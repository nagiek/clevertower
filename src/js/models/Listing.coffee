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
          if basedOnNetwork then network.inquiries 
          else if @get("property") and @get("property").inquiries then @get("property").inquiries
          else new InquiryList [], inquiry: @
        when "applicants"
          if basedOnNetwork then network.applicants 
          else if @get("property") and @get("property").applicants then @get("property").applicants
          else new ApplicantList [], inquiry: @

      @[collectionName]


    GPoint : ->
      new google.maps.LatLng @get("center")._latitude, @get("center")._longitude

    # Index of model in its collection.
    pos : -> @collection.indexOf(@)