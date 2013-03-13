# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.
  
# Address validation
Parse.Cloud.beforeSave "Address", (request, response) ->
  
  # unless ( request.object.get("center") != 0 and 
  #          request.object.get("lng") != 0
  # )
  # 
  #   # Invalid address
  #   response.error 'invalid_address'
  # else 
  unless (  request.object.get("thoroughfare"                ) != '' and 
            request.object.get("locality"                    ) != '' and
            request.object.get("administrative_area_level_1" ) != '' and
            request.object.get("country"                     ) != '' and
            request.object.get("postal_code"                 ) != ''
  )
    # Insufficient data
    response.error 'insufficient_data'
  else
    # Set to existing address, if exists.
    (new Parse.Query("Address"))
    .withinKilometers("center", request.object.get("center"), 0)
    .first()
    .then (obj) ->
      if obj?
      
        request.object.set "objectId", obj.get("objectId")
      
        # Perform checks for existing addresses.
        # -------------------------------------
      
        # Parse.Promise
        # .when([userAddressQuery(), networkAddressQuery()])
        # .then(obj1, obj2) ->
      
        # Validate user does not have a property here.
        (new Parse.Query("Property"))
        .equalTo("user"   , request.user       )
        .equalTo("address", obj.get "objectId" )
        .first()
        .then (obj) ->
          return response.error 'taken_by_user' if obj?
            
        # Validate network does not have a property here.
        # (new Parse.Query("Property"))
        # .equalTo("network", request.object.get "network")
        # .equalTo("address", obj.get "objectId"          )
        # .first()
        # .then (obj) ->
        #   return response.error 'taken_by_network' if obj?
            
      else
        # Keep this separate from above section, as we will hit it before promise completes.
        response.success()

# Property validation
Parse.Cloud.beforeSave "Property", (request, response) ->
  request.object.set "user", request.user
  return response.error 'title_missing' unless request.object.get("title")?
  response.success()
  
# Unit validation
Parse.Cloud.beforeSave "Unit", (request, response) ->
  request.object.set "user", request.user

# Lease validation
Parse.Cloud.beforeSave "Lease", (request, response) ->
  request.object.set "user", request.user

# Task validation
Parse.Cloud.beforeSave "Task", (request, response) ->
  request.object.set "user", request.user

# Task validation
Parse.Cloud.beforeSave "Income", (request, response) ->
  request.object.set "user", request.user

# Task validation
Parse.Cloud.beforeSave "Expense", (request, response) ->
  request.object.set "user", request.user