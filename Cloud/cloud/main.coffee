# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.
  
# Address validation
Parse.Cloud.define "CheckForUniqueProperty", (request, response) ->
  # Perform checks for existing addresses.
  # -------------------------------------

  # Parse.Promise
  # .when([userAddressQuery(), networkAddressQuery()])
  # .then(obj1, obj2) ->
  # Set to existing address, if exists.
  (new Parse.Query("Property"))
  .equalTo("user",            request.user  )
  .withinKilometers("center", request.params.center, 0.001)
  .first(
    success: (obj) ->
      return response.error "#{obj.id}:taken_by_user" if obj
      # request.object.set "objectId", obj.get("objectId")

      # Validate user does not have a property here.
      # (new Parse.Query("Property"))
      # .equalTo          ("network", request.object.get "network")
      # .withinKilometers ("center" , request.object.get("center"), 0.001)
      # .first(
      #   success: (obj) ->
      #     return response.error 'taken_by_user' if obj
      #     # Validate network does not have a property here.
      #     # (new Parse.Query("Property"))
      #     # .equalTo("network", request.object.get "network")
      #     # .equalTo("address", orig                         )
      #     # .first(
      #     #   success: (obj) ->
      #     #     return response.error 'taken_by_network' if obj?
      #     # )
      #     response.success()
      #   error: ->
      #     response.error 'bad_query'
      #   )
      response.success()
    error: ->
      response.error 'bad_query'
  )


# Property validation
Parse.Cloud.beforeSave "Property", (request, response) ->
  request.object.set "user", request.user
  
  unless ( +request.object.get("center") isnt +Parse.GeoPoint() )
    # Invalid address
    return response.error 'invalid_address'
  else unless ( 
    request.object.get("thoroughfare"                ) != '' and 
    request.object.get("locality"                    ) != '' and
    request.object.get("administrative_area_level_1" ) != '' and
    request.object.get("country"                     ) != '' and
    request.object.get("postal_code"                 ) != ''
  )
    # Insufficient data
    return response.error 'insufficient_data'
  else      
    return response.error 'title_missing' unless request.object.get("title")?
  response.success()

# Property permissions  
Parse.Cloud.afterSave "Property", (request) ->

  # Parse can only handle one role for now...
  unless request.object.existed()
    propertyACL = new Parse.ACL(request.user);
    current = new Parse.Role(request.object.id + "-mgr-current", propertyACL).save()
    # invited = new Parse.Role(request.object.id + "-mgr-invited", new Parse.ACL).save()
    # pending = new Parse.Role(request.object.id + "-mgr-pending", new Parse.ACL).save()  
    propertyACL.setRoleWriteAccess current
    # propertyACL.setRoleReadAccess invited
    request.object.setACL propertyACL
    request.object.save
  
# Unit validation
Parse.Cloud.beforeSave "Unit", (request, response) ->
  request.object.set "user", request.user
  response.success()

# Lease validation
Parse.Cloud.beforeSave "Lease", (request, response) ->
  request.object.set "user", request.user
  response.success()

# Task validation
Parse.Cloud.beforeSave "Task", (request, response) ->
  request.object.set "user", request.user
  response.success()

# Task validation
Parse.Cloud.beforeSave "Income", (request, response) ->
  request.object.set "user", request.user
  response.success()

# Task validation
Parse.Cloud.beforeSave "Expense", (request, response) ->
  request.object.set "user", request.user
  response.success()