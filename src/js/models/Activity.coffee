define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Activity = Parse.Object.extend "Activity",

    className: "Activity"

    defaults:
      title       : ""
      body        : ""
      post_type   : "status"

    GPoint : -> 
      center = @get "center"
      return new google.maps.LatLng 0,0 unless center
      new google.maps.LatLng center._latitude, center._longitude

    # Index of model in its collection.
    pos : -> @collection.indexOf(@)

    # Index of model in its collection.
    publicUrl : -> if @get("property") then @get("property").publicUrl() else "#"

    validate: (attrs = {}, options = {}) ->
      # Check all attribute existence, as validate is called on set
      # and save, and may not have the attributes in question.
      if attrs.start_date and attrs.end_date 
        if attrs.start_date is '' or attrs.end_date is ''
          return message: 'dates_missing'
        if moment(attrs.start_date).isAfter(attrs.end_date)
          return message: 'dates_incorrect'
      if attrs.unit
        if attrs.unit.id is ''
          return message: 'unit_missing'
        else if attrs.unit.isNew() and attrs.unit.isValid()
          # Validate associated  attrs.unit.attributes
          return error if error = attrs.unit.validationError
      false