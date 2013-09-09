define [
  'underscore'
  'backbone'
  'collections/ActivityList'
  'collections/CommentList'
  'collections/ApplicantList'
  'collections/TenantList'
], (_, Parse, ActivityList, CommentList, ApplicantList, TenantList) ->

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
      # Arrays
      likes               : true

    # Backbone default, as Parse function does not exist.
    url: -> "/users/#{@id}"

    cover: (format) ->
      switch format 
        when "micro", "tiny" then format = "thumb"
        when "large" then format = "full"
      img = @get "image_#{format}"
      img = "/img/fallback/avatar-#{format}.png" unless img
      img
      
    name: ->
      name = @get("name")
      unless name
        email = @get("email") 
        chunks = []
        email = "unknown@" unless email 
        _.each email.split("@")[0].split("."), (component) -> chunks.push _.str.capitalize(component)
        name = chunks.join(" ")
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
        when "activity"     then new ActivityList [], profile: @
        when "tenants"      then new TenantList [], profile: @
      @[collectionName]

    scrub: (attrs) ->
      bools = ['privacy_building']

      for attr in bools
        attrs[attr] = if attrs[attr] is "on" or attrs[attr] is "1" then true else false
      
      attrs