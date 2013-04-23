define [
  'underscore'
  'backbone'
  "collections/ApplicantList"
  "moment"
], (_, Parse, ApplicantList, moment) ->

  Inquiry = Parse.Object.extend "Inquiry",
  
    className: "Inquiry"

    defaults:
      comments: ""
      chosen: false
    
    validate: (attrs = {}, options = {}) ->
      # Check all attribute existence, as validate is called on set
      # and save, and may not have the attributes in question.
      if attrs.start_date and attrs.end_date 
        if attrs.start_date is '' or attrs.end_date is ''
          return message: 'dates_missing'
        if moment(attrs.start_date).isAfter(attrs.end_date)
          return message: 'dates_incorrect'
      false

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      switch collectionName
        when "applicants"
          user = Parse.User.current()
          network = user.get("network") if user
          unless user and network
            @[collectionName] = new ApplicantList [], inquiry: @
          else
            @[collectionName] = if network.applicants then network.applicants else new ApplicantList [], inquiry: @

      @[collectionName]