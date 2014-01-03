define [
  'underscore'
  'backbone'
  'collections/CommentList'
  # Cannot depend on ActivityList w/o creating dependency loop.
  # 'collections/ActivityList'
  'collections/ApplicantList'
  'collections/TenantList'
  "i18n!nls/common"
], (_, Parse, CommentList, ApplicantList, TenantList, i18nCommon) ->

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
    url: ->
      if @get "property" then @get("property").publicUrl()
      else if @get "location" then @get("location").url()
      else "/users/#{@id}" 
      
    followedByUser: -> Parse.User.current() and Parse.User.current().get("profile").following.any (p) => p.id is @id

    # Counts
    # If we have a relatively small number, count manually. Otherwise, use our count tracker.
    likesCount: -> if @likes and 0 < @likes.length < 500 then @likes.length else @get("likesCount") || 0
    followersCount: -> if @followers and 0 < @followers.length < 500 then @followers.length else @get("followersCount") || 0
    followingCount: -> if @following and 0 < @following.length < 500 then @following.length else @get("followingCount") || 0

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