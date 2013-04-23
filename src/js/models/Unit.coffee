define [
  'underscore'
  'backbone'
  "collections/LeaseList"
  "models/Property"
  "i18n!nls/unit"
], (_, Parse, LeaseList, Property, i18nUnit) ->

  class Unit extends Parse.Object
    
    className: "Unit"

    defaults:
      bathrooms       : 0
      bedrooms        : 0
      rent            : 0
      description     : ""
      square_feet     : ""
      title           : ""
      appliances      : ""

      # References
      # Will conflict with Parse.com schema.
      # user            : false
      # property        : false
      # active_lease    : false

      # Private
      confirmed       : true
      
    validate: (attrs = {}, options = {}) ->
      if attrs.title and attrs.title is ''
        return {message: 'title_missing'}
      false

    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      @[collectionName] = switch collectionName
        when "leases"
          property = @get("property")
          if property.leases then property.leases else new LeaseList [], unit: @
      @[collectionName]

