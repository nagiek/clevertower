define [
  'underscore',
  'backbone',
], (_, Parse, UnitList, LeaseList, Unit, Lease, inflection) ->

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

    cover: (format) ->
      img = @get "image_#{format}"
      img = "/img/fallback/avatar-#{format}.png" if img is '' or !img?
      img
      
    validate: (attrs, options) ->
      if attrs.email and attrs.email isnt ""
        return {message: "invalid_email"} unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test attrs.email
      false  
    