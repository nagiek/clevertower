
# Use Parse.Cloud.define to define as many cloud functions as you want.
# For example:
Parse.Cloud.define "hello", (request, response) ->
  response.success "Hello world!"
  
# Address validation
Parse.Cloud.beforeSave "Address", (request, response) ->
  unless request.object.get("lat") != 0 and request.object.get("lng") != 0
    # Invalid address
    response.error 'invalid_address'
  else unless (request.object.get("thoroughfare") != '' and 
  request.object.get("locality") != '' and
  request.object.get("administrative_area_level_1") != '' and
  request.object.get("country") != '' and
  request.object.get("postal_code") != ''
  )
    # Insufficient data
    response.error 'insufficient_data'
  else
    # Set to existing address, if exists.
    new Parse.Query("Address").equalTo("lat", request.object.get("lat")).equalTo("lng", request.object.get("lng")).find
      success: (results) -> request.object.set "id", results[0].get("id")

    response.success()

# Property validation
Parse.Cloud.beforeSave "Property", (request, response) ->
  
  unless request.object.get("title")?
    return response.error 'title_missing'

  # Validate user does not have a property here.
  new Parse.Query("Property").equalTo("userId", request.object.get("user")).equalTo("addressId", request.object.get("id")).find
    success: (results) -> 
      return response.error 'taken_by_user'

  # Validate network does not have a property here.
  new Parse.Query("Property").equalTo("networkId", request.object.get("network")).equalTo("addressId", request.object.get("id")).find
    success: (results) -> 
      return response.error 'taken_by_network'

  response.success()