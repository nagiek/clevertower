# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.

# AddTenants
# ----------
# THIS IS ONLY FOR adding tenants en masse to a lease, not to add any tenant.
# @see Tenant BeforeSave.
Parse.Cloud.define "AddTenants", (req, res) ->
  emails = req.params.emails
  return res.error unless emails
  
  propertyId = 
  _ = require "underscore"
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
  # Status is always 'invited', as we are saving a lease with
  # a joined tenant, instead of being a tenant trying to join.
  # In theory this could overwrite an application, but oh well.
  status = 'invited'
  (new Parse.Query "Property").include('mgrRole').get req.params.propertyId,
  success: (property) ->
    
    mgrRole = property.get "mgrRole"
    title = property.get "thoroughfare"
      
    # Notify the user.
    notification = new Parse.Object("Notification")
    notificationACL = new Parse.ACL
    
    # Lease Role
    (new Parse.Query "Lease").include('tntRole').get req.params.leaseId,
    success: (lease) ->
      
      tntRole = property.get "tntRole"
      if tntRole and mgrRole
        tenantRoleUsers = tntRole.getUsers() 
      
        # tenantACL
        tenantACL = new Parse.ACL
        tenantACL.setRoleReadAccess tntRole, true
        tenantACL.setRoleReadAccess mgrRole, true
        tenantACL.setRoleWriteAccess mgrRole, true
      
      # Create the tenants.
      (new Parse.Query "_User").containedIn("username", emails).find()
      .then (users) ->
        newUsersSignUps = []
        _.each emails, (email) ->
          found_user = false
          found_user = _.find users, (user) -> return user if email is user.get "email"
          
          if found_user
            # User exists
            tenant = new Parse.Object("Tenant")
            tenant.save(lease: lease, status: status, user: found_user, accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb", ACL: tenantACL)
            notificationACL.setReadAccess(found_user, true)
            tenantRoleUsers.add found_user if tntRole
            
          else
            # Notify the user
            Mandrill.sendEmail
              message:
                subject: "Using Cloud Code and Mandrill is great!"
                text: "Hello World!"
                from_email: "parse@cloudcode.com"
                from_name: "Cloud Code"
                to: [{email: email, name: email}]
              async: true
            ,
              success: (httpres) ->
              error: (httpres) ->
                
            # Generate random password.
            password = ""
            possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            for [1...8]
              password += possible.charAt Math.floor(Math.random() * possible.length)
              
            newUser = new Parse.User
              username: email
              password: password
              email: email
              ACL: new Parse.ACL()
              
            # Add the SignUp promise to the list of things to do.
            newUsersSignUps.push newUser.signUp()
            
        # Sign up new user.
        if newUsersSignUps.length > 0
          Parse.Promise.when(newUsersSignUps)
          .then ->
            _.each arguments, (user) ->
              tenant = new Parse.Object("Tenant")
              tenant.save(lease: lease, status: status, user: user, accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb", ACL: tenantACL)
              notificationACL.setReadAccess(user, true)
            notification.setACL notificationACL
            notification.save
            tenantRoleUsers.add user if tntRole
          , (error) ->
            res.error 'signup_error'
            
        else
          # Finish notifying the group.
          notification.setACL notificationACL
          notification.save
            text: "You have been invited to join #{title}"
            channels: [ "lease-#{req.params.leaseId}" ]
            name: "lease-invitation"
            
        tntRole.save() if tntRole
        res.success()
      
    , -> res.error "bad_query"
    
  error: ->
    res.error "bad_query"


# Address validation
Parse.Cloud.define "CheckForUniqueProperty", (req, res) ->
  
  (new Parse.Query("Property"))
  .equalTo("user",            req.user  )
  .withinKilometers("center", req.params.center, 0.001)
  .first()
  .then (obj) -> if obj then res.error "#{obj.id}:taken_by_user" else res.success(),
  -> res.error 'bad_query'
  
  # network = id: req.params.networkId, __type: pointer
  # (new Parse.Query("Property"))
  # .equalTo("network",         network  )
  # .withinKilometers("center", req.params.center, 0.001)
  # .first
  #   success: (obj) -> if obj then res.error "#{obj.id}:taken_by_network" else res.success()
  #   error: -> res.error 'bad_query'
  # 
  # Parse.Promise
  # .when([userAddressQuery(), networkAddressQuery()])
  # .then(obj1, obj2) ->


# User validation
Parse.Cloud.beforeSave "_User", (req, res) ->
  req.object.set "createdBy", req.user
  email = req.object.get "email"
  return res.error 'missing_username' if email is ''
  return res.error 'invalid_email' unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test email
  res.success()


# Property validation
Parse.Cloud.beforeSave "Property", (req, res) ->
    
  unless ( +req.object.get("center") isnt +Parse.GeoPoint() )
    # Invalid address
    return res.error 'invalid_address'
  else unless ( 
    req.object.get("thoroughfare"                ) != '' and 
    req.object.get("locality"                    ) != '' and
    req.object.get("administrative_area_level_1" ) != '' and
    req.object.get("country"                     ) != '' and
    req.object.get("postal_code"                 ) != ''
  )
    # Insufficient data
    return res.error 'insufficient_data'
  else
    return res.error 'title_missing' unless req.object.get("title")
    
  # Property permissions  
  existed = req.object.existed()
  propertyACL = if existed then req.object.getACL() else new Parse.ACL;
  
  # Parse can only handle one role for now...
  unless existed
    req.object.set "user", req.user
    
    # Role lists
    randomId = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for [1...16]
      randomId += possible.charAt Math.floor(Math.random() * possible.length)
    current = "mgr-current-" + randomId
    
    # Let members see and add other members.
    propertyACL.setRoleReadAccess current, true
    propertyACL.setRoleWriteAccess current, true
    
    # Create new role (API not chainable)
    role = new Parse.Role(current, propertyACL)
    role.getUsers().add(req.user)
    role.save().then (savedRole) -> 
      req.object.set "mgrRole", savedRole
      res.success()
      
  else
    isPublic = req.object.get "public"    
    if propertyACL.getPublicReadAccess() isnt isPublic
      propertyACL.setPublicReadAccess(isPublic)
      req.object.setACL propertyACL
    res.success()  


# Unit validation
Parse.Cloud.beforeSave "Unit", (req, res) ->
  
  res.error 'no_property' unless req.object.get "property"
  res.error 'no_title' unless req.object.get "title"
  
  propertyId = req.object.get("property").id
  
  unless req.object.existed()
    (new Parse.Query "Property").get propertyId,
    success: (model) -> 
      req.object.set "user", req.user
      req.object.setACL model.getACL()
      res.success()
    error: (model, error) ->
      res.error "bad_query"
  else
    res.success()


# Lease validation
Parse.Cloud.beforeSave "Lease", (req, res) ->
  
  # Validate
  unless req.object.get "unit"  then return res.error 'unit_missing'
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"
  unless start_date and end_date    then return res.error 'date_missing'
  if start_date is end_date         then return res.error 'date_missing'
  if start_date > end_date          then return res.error 'dates_incorrect'
  
  console.log 'validate start'  
  
  # Check for overlapping dates
  unit_date_query = (new Parse.Query("Lease")).equalTo("unit", req.object.get "unit")
  if req.object.existed() then unit_date_query.notEqualTo "id", req.object.get("unit")
  unit_date_query.find()
  .then (objs) ->
    _ = require 'underscore'
    _.each objs, (obj) ->
      sd = obj.get "start_date"
      if start_date <= sd and sd <= end_date then return res.error "#{obj.id}:overlapping_dates"
      ed = obj.get "end_date"
      if start_date <= ed and ed <= end_date then return res.error "#{obj.id}:overlapping_dates"
     
    console.log 'validate success'
    console.log req.object.existed()
    return res.success() if req.object.existed()
    console.log 'new success'
    
    # Change the status depending on who is creating the lease.
    propertyId = req.object.get("property").id
    (new Parse.Query "Property").include('mgrRole').get propertyId,
    success: (property) ->
      
      mgrRole = property.get "mgrRole"
      console.log 'role success'
      if mgrRole
        
        # Check if the user is in the role.
        # Users are in a Parse.Relation, which requires a second query.
        users = mgrRole.getUsers()
        users.query().get req.user.id,
        success: (obj) ->
          console.log 'users success'
          confirmed = if obj then true else false
          
          # Notify the property.
          unless confirmed
            name = user.get "name"
            notification = new Parse.Object("Notification")
            notificationACL = new Parse.ACL
            notificationACL.setRoleReadAccess(role, true)
            notification.setACL notificationACL
            notification.save
              name: "lease-application"
              text: "#{name} wants to join your property."
              channels: [ "property:#{propertyId}" ]
                                         
          # Set attributes
          req.object.set 
            user: req.user
            confirmed: confirmed
          
          # Prepare role
          existed = req.object.existed()
          leaseACL = if existed then req.object.getACL() else new Parse.ACL
          
          # Parse can only handle one role for now...
          unless existed
            
            # Role lists
            randomId = ""
            possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            for [1...16]
              randomId += possible.charAt Math.floor(Math.random() * possible.length)
            current = "tnt-current-" + randomId
            
            # Give tenants access to read the lease, and managers to read/write
            leaseACL.setRoleReadAccess current, true
            leaseACL.setRoleWriteAccess current, !confirmed
            leaseACL.setRoleWriteAccess mgrRole, true
            leaseACL.setRoleReadAccess mgrRole, true
            req.object.setACL leaseACL
            
            # Create new role (API not chainable)
            role = new Parse.Role(current, leaseACL)
            role.getUsers().add(req.user)
            role.save().then (savedRole) -> 
              req.object.set "tntRole", savedRole
              res.success()
              
          else
          
            # Check after each save if tenants should be allowed to edit
            if confirmed is leaseACL.getRoleWriteAccess current
              
              # Write status is the opposite of confirmed status
              leaseACL.setRoleWriteAccess current, !confirmed
              
              role.setACL leaseACL
              role.save()
              req.object.setACL leaseACL
              res.success()
            

            
        error: -> res.error "user_missing"
      else res.error "role_missing"
    error: -> res.error "bad_query"
  , -> res.error "bad_query"


# Lease After Save
Parse.Cloud.afterSave "Lease", (req) ->
  
  # Set active lease on unit
  today       = new Date
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"
  if start_date < today and today < end_date
    (new Parse.Query "Unit").get req.object.get("unit").id,
    success: (model) ->
      model.set "activeLease", req.object
      model.save()
  
  # Add the user to the lease, if they are not part of the property.    
  # Change the status depending on who is creating the link.
  propertyId = req.object.get("property").id
  (new Parse.Query "Property").include('mgrRole').get propertyId,
  success: (property) ->
    
    mgrRole = property.get "mgrRole"
    if mgrRole
      # Check if the user is in the role.
      # Users are in a Parse.Relation, which requires a second query.
      users = mgrRole.getUsers()
      users.query().get req.user.id,
      success: (obj) ->   
        # Check for emails.
        # We do this step after we have the role, because we may have
        # to add to users to the emails, or change notification.
        if obj 
          emails = req.object.get "emails"
          if emails then Parse.Cloud.run "AddTenants", {propertyId: propertyId, leaseId: req.object.id, emails: emails},
            success: (res) ->
            error: (res) ->
              
        else
          # Add current user as tenant
          emails = req.object.get("emails") || []
          emails.push req.user.get "email"
          req.object.set emails
          Parse.Cloud.run "AddTenants", {propertyId: propertyId, leaseId: req.object.id, emails: emails},
            success: (res) ->
            error: (res) ->


# Tenant validation
Parse.Cloud.beforeSave "Tenant", (req, res) ->
   
  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    req.object.unset "accessToken"
    return res.success()
    
  (new Parse.Query "Lease").include('tntRole').get req.object.get("lease").id,
  success: (lease) ->
    propertyId = lease.get("property").id
    user = req.object.get("User")
    status = req.object.get "status"
    tntRole = property.get "tntRole"
    
    # Change the status depending on who is creating the link.
    (new Parse.Query "Property").include('mgrRole').get propertyId,
    success: (property) ->
      mgrRole = property.get "mgrRole"
      
      # Set ACL
      unless req.object.existed()
        tenantACL = new Parse.ACL
        tenantACL.setRoleReadAccess tntRole, true if tntRole
        tenantACL.setRoleReadAccess mgrRole, true if mgrRole
        tenantACL.setRoleWriteAccess mgrRole, true if mgrRole
        req.object.setACL tenantACL
      
      if mgrRole
        # Check if the user is in the role.
        # Users are in a Parse.Relation, which requires a second query.
        users = mgrRole.getUsers()
        users.query().equalTo("user", user).first()
        .then (obj) ->
          if obj
              
            # Add the user to the tenant ACL list. Currently, there is only 
            # one list, but this may have to be divided in the future.
            tenantRole = lease.get "tntRole"
            tenantRole.getUsers().add req.object.get("user")
            tenantRole.save()
            
            # Notify the user.
            title = property.get "thoroughfare"
            notification = new Parse.Object("Notification")
            notificationACL = new Parse.ACL
            notificationACL.setReadAccess(req.object.get("user"), true)
            notification.setACL notificationACL
            notification.save
              name: "lease-invitation"
              text: "You have been invited to join #{title}"
              channels: [ "lease-#{lease.id}" ]
            
            # Upgrade the status
            status = if status and status is 'pending' then 'current' else 'invited'
            req.object.set "status", status
            res.success()
              
          else
            name = user.get "name"
            
            # Notify the property.
            notification = new Parse.Object("Notification")
            notificationACL = new Parse.ACL
            notificationACL.setRoleReadAccess(role, true)
            notification.setACL notificationACL
            notification.save
              name: "tenant-application"
              text: "#{name} wants to join your property."
              channels: [ "property-#{propertyId}" ]
            
            # Give property managers access to user.
            (new Parse.Query "_User").get user.id,
            success: (user) ->
              userACL = user.getACL
              userACL.setRoleReadAccess(mgrRole, true)
              user.save ACL: userACL
                        
            # There is only one lease role, so no need to change.
            status = if status and status is 'invited' then 'current' else 'pending'
            req.object.set "status", status
            res.success()
      else res.error "no matching role"
    error: -> res.error "bad_query"
  error: -> res.error "bad_query"


# Notification tasks
Parse.Cloud.afterSave "Notification", (req) ->
  
  # Executed in afterSave to avoid holding up any waiting.
  # Could place it beforeSave if there are consistent problems.
  return if req.object.get "error"
  
  C = require 'cloud/lib/crypto.js'
    
  method = 'POST'
  serverUrl = 'http://api.pusherapp.com'
  addedUrl = "/apps/40364/events"
  version = '1.0'
  
  key = 'dee5c4022be4432d7152'
  secret = 'b38f0a4b567af901adcf'
  timestamp = Math.round new Date().getTime() / 1000
  
  text = req.object.get 'text'
  body = 
    name: req.object.get 'name'
    data: JSON.stringify 
      text: text
      
  channels = req.object.get 'channels'
  if channels.length is 1 then body.channel = channels[0] else body.channels = channels
  
  body = JSON.stringify body
  body_md5 = C.CryptoJS.MD5(body).toString(C.CryptoJS.enc.Hex)
  
  string_to_sign = method + "\n" + 
    addedUrl + "\n" +
    "auth_key=#{key}" + 
    "&auth_timestamp=#{timestamp}" +
    "&auth_version=#{version}" + 
    "&body_md5=#{body_md5}"
  
  signature = C.CryptoJS.HmacSHA256(string_to_sign, secret).toString(C.CryptoJS.enc.Hex)
  
  Parse.Cloud.httpreq
    method: method,
    url: serverUrl + addedUrl,
    headers: 
      'Content-Type': 'application/json'
    body: body  
    params: 
      auth_key : key
      auth_timestamp : timestamp
      auth_version : version
      body_md5 : body_md5
      auth_signature : signature
    success: (httpres) ->
    error: (error) ->
      req.object.set "error", error.text
      req.object.save()  
  
  # Send a push notification
  Parse.Push.send 
    channels: req.object.get("channels"), data: alert: text
  , 
    # success: -> 
    error: (error) -> 
      req.object.set "error", JSON.stringify(error)
      req.object.save()


# Task validation
Parse.Cloud.beforeSave "Task", (req, res) ->
  req.object.set "user", req.user
  res.success()


# Income validation
Parse.Cloud.beforeSave "Income", (req, res) ->
  req.object.set "user", req.user
  res.success()


# Expense validation
Parse.Cloud.beforeSave "Expense", (req, res) ->
  req.object.set "user", req.user
  res.success()
