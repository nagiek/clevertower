define [
  'underscore'
  'backbone'
  "moment"
  "collections/CommentList"
  "collections/ProfileList"
  "gmaps"
], (_, Parse, moment, CommentList, ProfileList) ->

  Activity = Parse.Object.extend "Activity",

    className: "Activity"

    defaults:
      title:          ""
      activity_type:  "new_post"
      likersCount:    0
      commentCount:   0
      isEvent:        false
      wideAudience:   true

    GPoint : -> 
      center = @get "center"
      return new google.maps.LatLng 0,0 unless center
      new google.maps.LatLng center._latitude, center._longitude

    # Index of model in its collection.
    pos : -> @collection.indexOf(@)

    # Index of model in its collection.
    url : -> "/posts/#{@id}"

    validate: (attrs = {}, options = {}) ->
      # Check all attribute existence, as validate is called on set
      # and save, and may not have the attributes in question.
      if attrs.start_date and attrs.end_date 
        if moment(attrs.start_date).isAfter(attrs.end_date)
          return message: 'dates_incorrect'
      if attrs.unit
        if attrs.unit.id is ''
          return message: 'unit_missing'
        else if attrs.unit.isNew() and attrs.unit.isValid()
          # Validate associated  attrs.unit.attributes
          return error if error = attrs.unit.validationError
      false

    city: ->
      @get("locality").replace(/\s+/g, '-') + "--"
      + @get("administrative_area_level_1").replace(/\s+/g, '-') + "--"
      + Parse.App.countryCodes[@get("country")].replace(/\s+/g, '-')


    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]

      user = Parse.User.current()
      network = user.get("network") if user
      basedOnNetwork = user and network and @get("network") and @get("network").id is network.id

      @[collectionName] = switch collectionName
        when "comments"
          if basedOnNetwork then network.comments 
          else if @property() and @property().comments then @property().comments
          else
            new CommentList [], activity: @
        when "likers"
          # Independent
          likers = new ProfileList [], activity: @
          likers.query = @relation("likers").query()
          likers

      @[collectionName]


    # Accessing data functions
    # Avoid double-loading of profile/property data
    # ------------------------

    subject: -> if @collection and @collection.subject then @collection.subject else @get("subject")
    object: -> if @collection and @collection.object then @collection.object else @get("object")
    property: -> if @collection and @collection.property then @collection.property else @get("property")


    # User functions
    # -----------------

    likedByUser: -> Parse.User.current() and Parse.User.current().get("profile").likes.any (l) => l.id is @id


    # Display functions
    # -----------------

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
        when "new_listing", "new_property","new_tenant", "new_manager" then @profile().cover(size)
        when "new_post", "new_photo" then @get("image") || false
        else false

    title: -> if @get("title").indexOf("%NAME") isnt -1 then @get("title").replace("%NAME", @get("subject").name()) else @get("title")


  # CLASS METHODS
  # -------------

  Activity.city = (attrs) -> 
    attrs.locality.replace(/\s+/g, '-') + "--"
    + attrs.administrative_area_level_1.replace(/\s+/g, '-') + "--"
    + Parse.App.countryCodes[attrs.country].replace(/\s+/g, '-')

  Activity