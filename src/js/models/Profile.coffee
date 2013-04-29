define [
  'underscore',
  'backbone',
  'collections/ApplicantList'
], (_, Parse, ApplicantList) ->

  Profile = Parse.Object.extend "Profile"
    
    className: "Profile"
      
    initialize: ->
      _.bindAll @, "cover"
          
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

    # Backbone default, as Parse function does not exist.
    url: -> "/users/#{@id}"

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/avatar-#{format}.png" if img is '' or !img?
      img
      
    name: ->
      name = @get("name")
      unless name?
        email = @get("email") 
        chunks = []
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

      @[collectionName]