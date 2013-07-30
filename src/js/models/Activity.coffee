define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Activity = Parse.Object.extend "Activity",

    className: "Activity"

    defaults:
      title:          ""
      activity_type:  "new_post"
      likeCount:      0
      commentCount:   0
      isEvent:        false

    GPoint : -> 
      center = @get "center"
      return new google.maps.LatLng 0,0 unless center
      new google.maps.LatLng center._latitude, center._longitude

    # Index of model in its collection.
    pos : -> @collection.indexOf(@)

    # Index of model in its collection.
    url : -> "/outside/#{@id}"

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


    # Display functions
    # -----------------

    name: -> if @linkedToProperty() then @get('property').get("title") else @get('profile').name()
    profilePic: (size) -> if @linkedToProperty() then @get('property').cover(size) else @get('profile').cover(size)
    profileUrl: -> if @linkedToProperty() then @get('property').publicUrl() else @get('profile').url()
    linkedToProperty: -> @get('property') and not @get('profile')
    liked: -> Parse.User.current() and Parse.User.current().get("profile").likes.find (l) => l.id is @id

    title: ->
      switch @get "activity_type"
        when "new_post", "new_listing", "new_property" then @get("title")
        # when "new_property" then @get("property").get("title")
        when "new_photo" then @get("property").get("title")
        else false

    icon: ->
      switch @get "activity_type"
        when "new_listing" then "listing"
        when "new_property" then "building"
        when "new_photo" then "picture"        
        when "new_post" 
          if @get "public" then "globe" else "lock"
        else false

    image: (size) ->
      switch @get("activity_type")
        when "new_listing", "new_property" then @get('property').cover(size)
        when "new_post", "new_photo" then @get("image") || false
        when "new_tenant", "new_manager" then @get('profile').cover(size)
        else false