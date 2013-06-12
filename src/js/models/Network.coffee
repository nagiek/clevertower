define [
  'underscore'
  'backbone'
  'collections/PropertyList'
  'collections/ListingList'
  'collections/InquiryList'
  'collections/TenantList'
  'collections/ApplicantList'
  'collections/ManagerList'
], (_, Parse, PropertyList, ListingList, InquiryList, TenantList, ApplicantList, ManagerList) ->

  Network = Parse.Object.extend "Network",
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
      
    prep: (collectionName, options) ->
      return @[collectionName] if @[collectionName]
      @[collectionName] = switch collectionName
        when "properties"   then new PropertyList [], network: @
        when "managers"     then new ManagerList [], network: @
        when "tenants"      then new TenantList [], network: @
        when "applicants"   then new ApplicantList [], network: @
        when "listings"     then new ListingList [], network: @
        when "inquiries"    then new InquiryList [], network: @

      @[collectionName]

    publicUrl: -> "/networks/#{@id}"
    privateUrl: -> "#{location.protocol}//#{@get("name")}.#{location.host}"