# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.
  
# Address validation
Parse.Cloud.define "CheckForUniqueProperty", (request, response) ->
    
  (new Parse.Query("Property"))
  .equalTo("user",            request.user  )
  .withinKilometers("center", request.params.center, 0.001)
  .first
    success: (obj) -> if obj then response.error "#{obj.id}:taken_by_user" else response.success()
    error: -> response.error 'bad_query'
  
  # network = id: request.params.networkId, __type: pointer
  # (new Parse.Query("Property"))
  # .equalTo("network",         network  )
  # .withinKilometers("center", request.params.center, 0.001)
  # .first
  #   success: (obj) -> if obj then response.error "#{obj.id}:taken_by_network" else response.success()
  #   error: -> response.error 'bad_query'
  # 
  # Parse.Promise
  # .when([userAddressQuery(), networkAddressQuery()])
  # .then(obj1, obj2) ->

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
  
  saveFlag = false
  existed = request.object.existed()
  propertyACL = if existed then request.object.get "ACL" else new Parse.ACL;

  # Parse can only handle one role for now...
  unless existed
    saveFlag = true
    
    # Role lists
    current = request.object.id + "-mgr-current"
    # invited = request.object.id + "-mgr-invited"

    # Invited
    # new Parse.Role(invited, propertyACL).save()
    
    # Let members see and add other members.
    propertyACL.setRoleReadAccess current, true
    propertyACL.setRoleWriteAccess current, true
    
    # Create new role (API not chainable)
    role = new Parse.Role(current, propertyACL)
    role.getUsers().add(request.user)
    role.save()
    
    # # Invited
    # new Parse.Role(request.object.id + "-mgr-invited", propertyACL).save null,
    #   success: (invited) ->
    #     propertyACL.setRoleReadAccess invited
    #     request.object.setACL propertyACL
    #     request.object.save()
    # 


  else
    isPublic = request.object.get "public"    
    if propertyACL.getPublicReadAccess() isnt isPublic
      saveFlag = true
      propertyACL.setPublicReadAccess(isPublic)

  if saveFlag
    # Save the ACL
    request.object.setACL propertyACL
    request.object.save()


  
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