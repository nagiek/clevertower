# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.
  
# Address validation
Parse.Cloud.define "CheckForUniqueProperty", (request, response) ->
    
  (new Parse.Query("Property"))
  .equalTo("user",            request.user  )
  .withinKilometers("center", request.params.center, 0.001)
  .first()
  .then (obj) -> if obj then response.error "#{obj.id}:taken_by_user" else response.success(),
  -> response.error 'bad_query'
  
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


Parse.Cloud.beforeSave "_User", (request, response) ->
  request.object.set "createdBy", request.user
  email = request.object.get "email"
  return response.error 'missing_username' if email is ''
  return response.error 'invalid_email' unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test email
  response.success()

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
  propertyACL = if existed then request.object.getACL() else new Parse.ACL;

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
  
  property = request.object.get "property"
  response.error 'no_property' unless property
  response.error 'no_title' unless request.object.get "title"

  unless request.object.existed()
    (new Parse.Query "Property").get property.objectId,
    success: (model) ->
    
      request.object.set "user", request.user
      request.object.setACL model.getACL()
      console.log model.getACL()
      response.success()
    
    error: (model, error) ->
      response.error "bad_query"
  else
    response.success()

# Lease validation
Parse.Cloud.beforeSave "Lease", (request, response) ->
  unless request.object.get "unit"  then return response.error 'unit_missing'

  start_date  = request.object.get "start_date"
  end_date    = request.object.get "end_date"
  unless start_date and end_date    then return response.error 'date_missing'
  if start_date is end_date         then return response.error 'date_missing'
  if start_date > end_date          then return response.error 'dates_incorrect'

  # Check for overlapping dates
  unit_date_query = (new Parse.Query("Lease")).equalTo("unit", request.object.get "unit")
  unit_date_query.notEqualTo "id", request.object.get("unit")  if request.object.existed()
  unit_date_query.find()
  .then (objs) -> 
    _ = require 'underscore'
    _.each objs, (obj) ->
      sd = obj.get "start_date"
      if start_date < sd and sd < end_date then return response.error "#{obj.id}:overlapping_dates"
      ed = obj.get "end_date"
      if start_date < ed and ed < end_date then return response.error "#{obj.id}:overlapping_dates"
      
    return response.success() if request.object.existed()
    
    property = request.object.get "property"
    
    (new Parse.Query "Property").get property.objectId,
    success: (model) ->
      modelACL = model.getACL()
      request.object.set 
        user: request.user
        confirmed: modelACL.getReadAccess(request.user) # _.contains(role.getUsers(), request.object.get("User"))
        
      request.object.setACL modelACL
      response.success()
    error: (model, error) ->
      response.error "bad_query"


# Lease After Save
Parse.Cloud.afterSave "Lease", (request) ->
  
  # Set active lease on unit
  today       = new Date
  start_date  = request.object.get "start_date"
  end_date    = request.object.get "end_date"
  if start_date < today and today < end_date
    (new Parse.Query "Unit").get request.object.get("unit").objectId,
    success: (model) ->
      model.set "has_lease", true
      model.set "activeLease", request.object
      model.save()
  
  # Check to see if we are adding people to the lease.
  # This is the same code as in Tenant BeforeSave, but done en masse.
  emails = request.object.get "emails"
  if emails
    propertyId = request.object.get("property").objectId
    
    # Change the status depending on who is creating the link.
    (new Parse.Query "Role").equalTo("name", "#{propertyId}-mgr-current").first()
    .then (property) ->
      _ = require "underscore"
      
      # Status is always 'invited', as we are saving a lease with
      # a joined tenant, instead of being a tenant trying to join.
      status = 'invited'
    
      # Create the tenants.
      _.each emails, (email) ->
        (new Parse.Query "_User").equalTo("username", email).first()
        .then (user) ->
          if user
            # User exists
            tenant = new Parse.Object("Tenant")
            tenant.save(lease: request.object, status: status, user: user, bypassToken: "AZeRP2WAmb")
            
          else

            # Generate random password.
            password = ""
            possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            for [1...8]
              password += possible.charAt Math.floor(Math.random() * possible.length)

            # Sign up new user.
            Parse.User.signUp email, password, { email: email, ACL: new Parse.ACL() }, 
            success: (user) ->
              tenant = new Parse.Object("Tenant")
              tenant.save(lease: request.object, status: status, user: user, bypassToken: "AZeRP2WAmb")
      

# Tenant validation
Parse.Cloud.beforeSave "Tenant", (request, response) ->
  return response.success() if request.object.existed() or request.object.get("bypassToken") is "AZeRP2WAmb"

  (new Parse.Query "Lease").get request.object.get("lease").objectId,
  success: (lease) ->
    propertyId = lease.get("property").objectId
    # Change the status depending on who is creating the link.
    (new Parse.Query "Role").equalTo("name", "#{propertyId}-mgr-current").first()
    .then (role) ->
      if role
        # Check if the user is in the role.
        # Users are in a Parse.Relation, which requires a second query.
        users = role.getUsers()
        users.query().equalTo("user", request.object.get("User")).first()
        .then (obj) ->
          if obj      
            status = 'invited'
            request.object.set "status", status
            response.success()
          else
            status = 'pending'
            request.object.set "status", status
            response.success()
      else
        response.error "no matching role"
    , ->
      response.error "bad_query"

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