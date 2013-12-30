define [
  'underscore'
  'backbone'
  'collections/CommentList'
  # Cannot depend on ActivityList w/o creating dependency loop.
  # 'collections/ActivityList'
  'collections/ApplicantList'
  'collections/TenantList'
], (_, Parse, CommentList, ApplicantList, TenantList) ->

  Profile = Parse.Object.extend "Profile",
    
    className: "Profile"
      
    initialize: ->
              
    defaults:
      # Name
      name                : ""
      first_name          : ""
      last_name           : ""
      # Images
      image_thumb         : ""
      image_profile       : ""
      image_full          : ""
      # Fields
      bio                 : ""
      website             : ""
      phone               : ""
      # Privacy
      privacy_building    : true
      # Counts
      likesCount          : 0
      followersCount      : 0
      followingCount      : 0

    # Backbone default, as Parse function does not exist.
    url: -> if @get "user" then "/users/#{@id}" else @propertyUrl()
    followedByUser: -> Parse.User.current() and Parse.User.current().get("profile").following.any (p) => p.id is @id

    # URL friendly title for properties
    propertyUrl: -> "/places/#{@country()}/#{@get("property").get("administrative_area_level_1")}/#{@get("property").get("locality")}/#{@id}/#{@slug()}"
    slug: -> @get("name").replace(/\s+/g, '-').toLowerCase()
    country: -> Parse.App.countryCodes[@get("property").get("country")]

    cover: (format) ->
      switch format
        when "micro", "tiny" then getFormat = "thumb"
        when "large", "profile", "span4", "span6" then getFormat = "full"
        else getFormat = format
      img = @get "image_#{getFormat}"
      unless img
        img = if @get "property" then "/img/fallback/property-#{format}.png"
        else "/img/fallback/avatar-#{format}.png"
        
      img
      
    name: ->
      name = @get("name")
      unless name
        name = @get("first_name") & " " & @get("last_name")
      unless name
        email = @get("email") 
        if email
          chunks = []
          _.each email.split("@")[0].split("."), (component) -> chunks.push _.str.capitalize(component)
          name = chunks.join(" ")
        else 
          name = "unknown"
      name
      
    validate: (attrs, options) ->
      if attrs.email and attrs.email isnt ""
        return {message: "invalid_email"} unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test attrs.email
      false  
    
    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]

      @[collectionName] = switch collectionName
        when "applicants"   then new ApplicantList [], profile: @
        when "comments"     then new CommentList [], profile: @
        # when "activity"     then new ActivityList [], profile: @
        when "tenants"      then new TenantList [], profile: @
      @[collectionName]

    scrub: (attrs) ->
      bools = ['privacy_building']

      for attr in bools
        attrs[attr] = if attrs[attr] is "on" or attrs[attr] is "1" then true else false
      
      attrs