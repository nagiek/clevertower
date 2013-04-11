define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Network = Parse.Object.extend "Network"
  # class Property extends Parse.Object
    
    className: "Network"
      
    defaults:
      name:     ""
      title:    ""
      phone:    ""
      email:    ""
      website:  ""
      
    validate: (attrs = {}, options = {}) ->
      if attrs.name
        # Return if there is anything but a lowercase letter.
        name = attrs.name
        return message: 'name_missing'    unless name
        return message: 'name_reserved'   if name is 'edit' or name is 'show' or name is 'new' or name is 'delete' or name is 'www'
        return message: 'name_too_short'  unless name.length > 3
        return message: 'name_too_long'   if name.length > 31
        return message: 'name_invalid'    unless /^[a-z]+$/.test name
      false
    