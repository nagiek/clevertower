# Parse.Cloud functions are asynchronous!!
# Always use promises with expensive functions, like queries.

# AddTenants
# ----------
# This can be called by managers or tenants.
# Can be done on either Leases or Inquiries, but always comes from an invitational perspective
# @see Tenant BeforeSave.
Parse.Cloud.define "AddTenants", (req, res) ->
  emails = req.params.emails
  className = req.params.className
  return res.error("emails_missing") unless emails
  
  _ = require "underscore"
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
  # Status is always 'invited', as we are saving a lease with
  # a joined tenant, instead of being a tenant trying to join.
  # In theory this could overwrite an inquiry, but oh well.
  status = 'invited'
  (new Parse.Query "Property").include('network.role').get req.params.propertyId,
  success: (property) ->
    
    network = property.get "network"
    mgrRole = network.get "role"
    title = property.get "thoroughfare"
    
    # Lease/Applicant Role
    (new Parse.Query className).include('role').get req.params.objectId,
    success: (obj) ->
      
      tntRole = obj.get "role"
      joinClassName = if className is "Lease" then "Tenant" else "Applicant"
      joinClassACL = new Parse.ACL
      
      # Set to be totally open: will close when the user registers
      profileACL = new Parse.ACL
      profileACL.setPublicReadAccess true
      profileACL.setPublicWriteAccess true
      
      if tntRole
        tntRoleUsers = tntRole.getUsers() 
        joinClassACL.setRoleReadAccess tntRole, true
        
      if mgrRole
        joinClassACL.setRoleReadAccess mgrRole, true
        joinClassACL.setRoleWriteAccess mgrRole, true
              
      # Create the joinClass.
      # Query for the profile and include the user to add to roles
      (new Parse.Query "Profile").include("user").containedIn("email", emails).find()
      .then (profiles) ->
        newProfileSaves = new Array()
        _.each emails, (email) ->
          found_profile = false
          found_profile = _.find profiles, (profile) -> return profile if email is profile.get "email"
          
          if found_profile
            
            # Profile exists, but user does not necessarily exist.
            joinClass = new Parse.Object joinClassName
            notification = new Parse.Object "Notification"
            user = found_profile.get("user")

            # Save the joinClass
            vars = 
              property: property
              network: network
              status: if user and user.id is req.user.id then 'accepted' else status
              profile: found_profile
              accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
              ACL: joinClassACL
            vars[className.toLowerCase()] = obj
            vars.listing = obj.get("listing") if obj.get("listing")
            joinClass.save vars
            
            
            notificationACL = new Parse.ACL()
            if user
              tntRoleUsers.add user if tntRole
              notificationACL.setReadAccess(user, true)
              notificationACL.setWriteAccess(user, true)

            # Send a notification, unless it is to us.
            unless user and user.id is req.user.id then notification.save
              text: "You have been invited to join #{title}"
              channels: [ "profiles-#{found_profile.id}" ]
              channel: "profiles-#{found_profile.id}"
              name: "#{className}_invitation".toLowerCase()
              forMgr: false
              property: property
              network: network
              ACL: notificationACL
            
          else
            newProfile = new Parse.Object "Profile"
              
            # Add the SignUp promise to the list of things to do.
            newProfileSaves.push newProfile.save
              email: email
              ACL: profileACL
            
        # Sign up new user.
        if newProfileSaves.length > 0
          Parse.Promise.when(newProfileSaves)
          .then ->
            _.each arguments, (profile) ->
              joinClass = new Parse.Object joinClassName

              # Save the joinClass
              vars = 
                property: property
                network: network
                status: status
                profile: profile
                accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
                ACL: joinClassACL
              vars[className.toLowerCase()] = obj
              vars.listing = obj.get("listing") if obj.get("listing")
              joinClass.save vars
              
              new Parse.Object("Notification").save
                text: "You have been invited to join #{title}"
                channels: [ "profiles-#{profile.id}" ]
                channel: "profiles-#{profile.id}"
                name: "#{className}_invitation".toLowerCase()
                forMgr: false
                property: property
                network: network
                ACL: new Parse.ACL()
                
              # Notify the user
              Mandrill.sendEmail
                message:
                  subject: "You have been invited to try CleverTower"
                  text: "Hello World!"
                  from_email: "parse@cloudcode.com"
                  from_name: "Cloud Code"
                  to: [{email: profile.get("email"), name: profile.get("email")}]
                async: true
              ,
                success: (httpres) ->
                error: (httpres) ->
              
              
            tntRole.save() if tntRole
            res.success obj
              
          , (error) ->
            res.error 'signup_error'
            
        else                        
          tntRole.save() if tntRole
          res.success obj
      
    , -> res.error "bad_query"
    
  error: ->
    res.error "bad_query"


# AddManagers
# ----------
# THIS IS ONLY FOR adding tenants en masse to a lease, not to add any tenant.
# @see Tenant BeforeSave.
Parse.Cloud.define "AddManagers", (req, res) ->
  emails = req.params.emails
  return res.error("emails_missing") unless emails
  
  _ = require "underscore"
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
  # Status is always 'invited', as we are saving a lease with
  # a joined tenant, instead of being a tenant trying to join.
  # In theory this could overwrite an inquiry, but oh well.
  status = 'invited'
  (new Parse.Query "Network").include('role').get req.params.networkId,
  success: (network) ->
    
    mgrRole = network.get "role"
    managerACL = new Parse.ACL
    title = network.get "title"
    
    # Set to be totally open: will close when the user registers
    profileACL = new Parse.ACL
    profileACL.setPublicReadAccess true
    profileACL.setPublicWriteAccess true
    
    if mgrRole
      managerACL.setRoleReadAccess mgrRole, true
      managerACL.setRoleWriteAccess mgrRole, true
      mgrRoleUsers = mgrRole.getUsers()
      
    # Create the managers.
    # Query for the profile and include the user to add to roles
    (new Parse.Query "Profile").include("user").containedIn("email", emails).find()
    .then (profiles) ->
      newProfileSaves = new Array()
      newManagerSaves = new Array()
      _.each emails, (email) ->
        found_profile = false
        found_profile = _.find profiles, (profile) -> return profile if email is profile.get "email"
        
        if found_profile
          # Profile exists, but user does not necessarily exist.
          manager = new Parse.Object "Manager"
          notification = new Parse.Object "Notification"
          user = found_profile.get("user")
          
          if user
            notification.setACL new Parse.ACL().setReadAccess(user, true).setWriteAccess(found_profile.get("user"), true)
            mgrRoleUsers.add user if mgrRole
          else
            notification.setACL new Parse.ACL()
          
          newManagerSaves.push manager.save
            network: network
            status: status
            admin: false
            profile: found_profile
            accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
            ACL: managerACL
            
          # Notify the user
          notification.save
            text: "You have been invited to join #{title}"
            channels: [ "profiles-#{found_profile.id}" ]
            channel: "profiles-#{found_profile.id}"
            name: "network_invitation"
            forMgr: true
            network: network
          
        else
          # Add the SignUp promise to the list of things to do.
          newProfile = new Parse.Object "Profile"
          newProfileSaves.push newProfile.save
            email: email
            ACL: profileACL
          
      # Sign up new user.
      if newProfileSaves.length > 0
        Parse.Promise.when(newProfileSaves)
        .then ->
          _.each arguments, (profile) ->
            manager = new Parse.Object("Manager")
            
            newManagerSaves.push manager.save
              network: network
              status: status
              admin: false
              profile: profile
              accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
              ACL: managerACL
            
            console.log manager
            
            # Notify the user
            Mandrill.sendEmail
              message:
                subject: "You have been invited to try CleverTower"
                text: "Hello World!"
                from_email: "parse@cloudcode.com"
                from_name: "Cloud Code"
                to: [{email: profile.get("email"), name: profile.get("email")}]
              async: true
            ,
              success: (httpres) ->
              error: (httpres) ->
                
            # Add a Notification for when they register.
            new Parse.Object("Notification").save
              text: "You have been invited to join #{title}"
              channels: [ "profiles-#{profile.id}" ]
              channel: "profiles-#{profile.id}"
              name: "network_invitation"
              forMgr: true
              network: network
              ACL: new Parse.ACL()
              
          mgrRole.save() if mgrRole
          Parse.Promise.when(newManagerSaves).then ->
            
            # Cannot return accessToken.
            # Cannot use the unset method without alerting Parse that we have created a "dirty" object
            _.each arguments, (obj) -> delete obj.attributes.accessToken
            
            # Must return object.
            res.success arguments
            
        , (error) -> res.error 'signup_error'          
      else
        mgrRole.save() if mgrRole
        Parse.Promise.when(newManagerSaves).then -> 
        
          # Cannot return accessToken.
          # Cannot use the unset method without alerting Parse that we have created a "dirty" object.
          _.each arguments, (obj) -> delete obj.attributes.accessToken
          
          # Must return object.
          res.success arguments
                  
  , -> res.error "bad_query"
  
  error: ->
    res.error "bad_query"


# Address validation
Parse.Cloud.define "CheckForUniqueProperty", (req, res) ->
  
  userAddressQuery = (new Parse.Query("Property"))
  .equalTo("user",            req.user  )
  .withinKilometers("center", req.params.center, 0.001)
  .first()
  
  network = id: req.params.networkId, __type: "Pointer", className: "_Role"
  networkAddressQuery = (new Parse.Query("Property"))
  .equalTo("network",         network  )
  .withinKilometers("center", req.params.center, 0.001)
  .first()
  
  Parse.Promise
  .when(userAddressQuery, networkAddressQuery)
  .then (obj1, obj2) ->
    if obj1 then return res.error "#{obj1.id}:taken_by_user"
    if obj2 then return res.error "#{obj2.id}:taken_by_network" 
    res.success()
  , -> res.error 'bad_query'


# User validation
Parse.Cloud.beforeSave "Profile", (req, res) ->
  
  # email = req.object.get "email"
  # return res.error 'missing_username' if email is ''
  # return res.error 'invalid_email_format' unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test email
  
  req.object.set "createdBy", req.user unless req.object.existed()
  
  res.success()


# User after save
Parse.Cloud.afterSave "_User", (req, res) ->
  
  return if req.object.existed()
  
  email = req.object.get "email"
  
  # Map the user to the profile, if any.
  (new Parse.Query "Profile").equalTo('email', email).first()
  .then (profile) ->
    
    # Create a new ACL, as the existing one is set to public/public.
    # We will add to the ACL later.
    profileACL = new Parse.ACL()
    profileACL.setPublicReadAccess true
    profileACL.setWriteAccess req.object, true
    
    unless profile
      profile = new Parse.Object("Profile")
      profile.save 
        email: email
        ACL: profileACL
        user: req.object
      
    else
      _ = require "underscore"
      
      # Include the user into any properties they have been invited to.
      (new Parse.Query "Manager").include('network.role').equalTo('profile', profile).find()
      .then (objs) ->
        _.each objs, (obj) ->
          role = obj.get("network").get("role")
          if role
            role.getUsers().add req.obj
            role.save()
        (new Parse.Query "Tenant").include('lease.role').equalTo('profile', profile).find()
        .then (objs) ->
          _.each objs, (obj) ->
            role = obj.get("lease").get("role")
            if role
              role.getUsers().add req.obj
              role.save()
              
            (new Parse.Query "Notification").equalTo('channel', "profiles-#{profile.id}").find()
            .then (objs) ->
              _.each objs, (obj) ->
                role = obj.get("lease").get("role")
                if role
                  role.getUsers().add req.obj
                  role.save()
            
            
              # No more steps. Save.
              profile.save
                email: req.object.get("email")
                user: req.object
                ACL profileACL


# Network validation
Parse.Cloud.beforeSave "Network", (req, res) ->
  
  name = req.object.get "name"
  return res.error 'name_missing'   unless name
  return res.error 'name_reserved'  if name is 'edit' or name is 'show' or name is 'new' or name is 'delete' or name is 'www'
  return res.error 'name_too_short' unless name.length > 3
  return res.error 'name_too_long'  if name.length > 31
  return res.error 'name_invalid'   unless /^[a-z]+$/.test name
  
  query = (new Parse.Query "Network").equalTo('name', name)
  if req.object.existed() then query.notEqualTo 'objectId', req.object.id
  query.first().then (obj) ->
    return res.error "#{obj.id}:name_taken" if obj
    return res.success() if req.object.existed()
    
    networkACL = new Parse.ACL()
    
    # Parse can only handle one role for now...    
    # Role lists
    randomId = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for [1...16]
      randomId += possible.charAt Math.floor(Math.random() * possible.length)
    current = "mgr-current-" + randomId
    
    # Let members see and add other members.
    networkACL.setRoleReadAccess current, true
    networkACL.setRoleWriteAccess current, true
    req.object.setACL networkACL
    
    # Create new role (API not chainable)
    role = new Parse.Role(current, networkACL)
    role.getUsers().add(req.user)
    role.save().then (savedRole) -> 
      req.object.set "role", savedRole
      res.success()
    , ->
      res.error "role_error"
      
  , ->
    res.error "bad_query"


# Network after save
Parse.Cloud.afterSave "Network", (req, res) ->
  unless req.object.existed()
      
    # Save the user as a manager
    (new Parse.Query "Profile").equalTo('user', req.user).first()
    .then (profile) ->
      # Query for the role, as we need the role's name to adjust the ACL.
      (new Parse.Query "_Role").get req.object.get("role").id,
      success: (role) ->
        manager = new Parse.Object("Manager")
        managerACL = new Parse.ACL
        managerACL.setRoleReadAccess role, true
        managerACL.setRoleWriteAccess role, true
      
        manager.save
          network: req.object
          status: 'accepted'
          admin: true
          profile: profile
          accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
          ACL: managerACL
          
        # Save a convenient reference to the network.
        req.user.save network: req.object


# Property validation
Parse.Cloud.beforeSave "Property", (req, res) ->
    
  unless ( +req.object.get("center") isnt +Parse.GeoPoint() )
    # Invalid address
    return res.error 'invalid_address'
  else if ( 
    req.object.get("thoroughfare"                ) is '' or 
    req.object.get("locality"                    ) is '' or
    req.object.get("administrative_area_level_1" ) is '' or
    req.object.get("country"                     ) is '' or
    req.object.get("postal_code"                 ) is ''
  )
    # Insufficient data
    return res.error 'insufficient_data'
  else
    return res.error 'title_missing' unless req.object.get("title")
    
  unless req.object.existed()
    query = (new Parse.Query "Network").get req.user.get("network").id,
    success : (network) ->

      # Do not make a role for tenants: can be done with simple ACL.
      req.object.set
        user: req.user
        network: network
        ACL: network.getACL()

      res.success()

    error : -> 
      res.error 'bad_query'
      
  else
    isPublic = req.object.get "public"
    propertyACL = req.object.getACL()
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


# Inquiry validation
Parse.Cloud.beforeSave "Inquiry", (req, res) ->
  
  existed = req.object.existed()

  # Validate
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"
  listing     = req.object.get "listing"
  unless start_date and end_date    then return res.error 'date_missing'
  if start_date is end_date         then return res.error 'date_missing'
  if start_date > end_date          then return res.error 'dates_incorrect'
  unless listing                    then return res.error 'listing_missing'
       
  return res.success() if existed

  (new Parse.Query("Listing")).include('network.role').get listing.id,
  success: (obj) ->

    property = obj.get("property")
    network = obj.get("network")
    role = network.get("role")

    # Add user to tenants.
    emails = req.object.get("emails") || []
    emails.push req.user.get "email"

    # Set attributes
    req.object.set 
      user: req.user
      emails: emails
      # Get these from a trusted source.
      listing: obj
      unit: obj.get("unit")
      property: property
      network: network

    # Notify the property.
    name = req.user.get "name"
    notification = new Parse.Object("Notification")
    notificationACL = new Parse.ACL()
    notificationACL.setRoleReadAccess(role, true)
    notificationACL.setRoleWriteAccess(role, true)
    notification.save
      name: "new_inquiry"
      text: "#{name} wants to join your property."
      channels: [ "networks-#{network.id}", "properties-#{property.id}" ]
      channel: "networks-#{network.id}"
      forMgr: true
      property: property
      network: network
      ACL: notificationACL
      
    # Give tenants access to read the lease, and managers to read/write
    leaseACL = new Parse.ACL
    leaseACL.setReadAccess req.user.id, true
    leaseACL.setWriteAccess req.user.id, true
    leaseACL.setRoleWriteAccess role, true
    leaseACL.setRoleReadAccess role, true
    req.object.setACL leaseACL
    
    res.success()

  error: -> res.error "bad_query"


# Lease After Save
Parse.Cloud.afterSave "Inquiry", (req) ->
  Parse.Cloud.run "AddTenants", {
    propertyId: req.object.get("property").id
    objectId: req.object.id
    emails: req.object.get "emails"
    className: "Inquiry"
  },
  success: (res) ->
  error: (res) ->


# Lease validation
Parse.Cloud.beforeSave "Lease", (req, res) ->
  
  existed = req.object.existed()

  # Validate
  unless req.object.get "unit"  then return res.error 'unit_missing'
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"
  unless start_date and end_date    then return res.error 'date_missing'
  if start_date is end_date         then return res.error 'date_missing'
  if start_date > end_date          then return res.error 'dates_incorrect'
  
  # Check for overlapping dates
  unit_date_query = (new Parse.Query("Lease")).equalTo("unit", req.object.get "unit")
  if existed then unit_date_query.notEqualTo "id", req.object.get("unit")
  unit_date_query.find()
  .then (objs) ->
    _ = require 'underscore'
    _.each objs, (obj) ->
      sd = obj.get "start_date"
      if start_date <= sd and sd <= end_date then return res.error "#{obj.id}:overlapping_dates"
      ed = obj.get "end_date"
      if start_date <= ed and ed <= end_date then return res.error "#{obj.id}:overlapping_dates"
     
    return res.success() if existed

    # Set default attributes
    req.object.set 
      user: req.user
      confirmed: false
    
    # Change the status depending on who is creating the lease.
    propertyId = req.object.get("property").id
    (new Parse.Query "Property").include('network.role').get propertyId,
    success: (property) ->
      
      network = property.get("network")
      mgrRole = network.get("role")
      if mgrRole
        
        # Check if the user is in the role.
        # Users are in a Parse.Relation, which requires a second query.
        users = mgrRole.getUsers()
        users.query().get req.user.id,
        success: (obj) ->

          if obj?
            req.object.set "confirmed", true
          else
            emails = req.object.get "emails" || []
            emails.push req.user.getEmail()
            req.object.set "emails", emails
            
          # Role lists
          randomId = ""
          possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
          for [1...16]
            randomId += possible.charAt Math.floor(Math.random() * possible.length)
          current = "tnt-current-" + randomId

          # Give tenants access to read the property, and managers to read/write
          leaseACL = new Parse.ACL
          leaseACL.setRoleReadAccess current, true
          leaseACL.setRoleWriteAccess mgrRole, true
          leaseACL.setRoleReadAccess mgrRole, true
          req.object.setACL leaseACL

          # Create new role (API not chainable)
          # Prepare a role for tenants
          role = new Parse.Role(current, leaseACL)
          role.save().then (savedRole) -> 
            req.object.set "role", savedRole
            res.success()
          , ->
            # TODO: Once more roles are available, change this to res.error()
            res.success()

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
  
  Parse.Cloud.run "AddTenants", {
    propertyId: req.object.get("property").id
    objectId: req.object.id
    emails: req.object.get("emails")
    className: "Lease"
  },
  success: (res) ->
  error: (res) ->

# Lease validation
Parse.Cloud.beforeSave "Listing", (req, res) ->
  
  # Validate
  unless req.object.get "unit"  then return res.error 'unit_missing'
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"
  unless start_date and end_date    then return res.error 'date_missing'
  if start_date is end_date         then return res.error 'date_missing'
  if start_date > end_date          then return res.error 'dates_incorrect'
  unless req.object.get "title"     then return res.error 'title_missing'
  unless req.object.get "rent"      then return res.error 'rent_missing'
  
  return res.success() if req.object.existed()

  (new Parse.Query "Property").include('network.role').get req.object.get("property").id,
  success: (property) ->

    # Update the listing with the location
    req.object.set "center", property.get("center")

    network = property.get "network"
    mgrRole = network.get "role"
  
    # Give public access to read the lease, and managers to read/write
    listingACL = new Parse.ACL()
    listingACL.setPublicReadAccess true
    listingACL.setRoleWriteAccess mgrRole, true
    listingACL.setRoleReadAccess mgrRole, true
    req.object.setACL listingACL
    res.success()


# Tenant validation
Parse.Cloud.beforeSave "Tenant", (req, res) ->

  className = if req.object.get("lease") then "Lease" else "Inquiry"

  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    req.object.unset "accessToken"
    return res.success()
    
  (new Parse.Query className).include('role').get req.object.get(className.toLowerCase()).id,
  success: (obj) ->
    propertyId = obj.get("property").id
    profile = req.object.get "profile"
    user = profile.get "user"
    status = req.object.get "status"
    tntRole = obj.get "role"
    
    # Change the status depending on who is creating the link.
    (new Parse.Query "Property").include('network.role').get propertyId,
    success: (property) ->
      network = property.get "network"
      mgrRole = network.get "role"
      
      # Set ACL
      unless req.object.existed()
        tenantACL = new Parse.ACL
        tenantACL.setRoleReadAccess tntRole, true if tntRole
        tenantACL.setRoleReadAccess mgrRole, true if mgrRole
        tenantACL.setRoleWriteAccess mgrRole, true if mgrRole
        req.object.set 
          network: network
          ACL: tenantACL
      
      if mgrRole
        # Check if the REQUEST user is in the role.
        # Users are in a Parse.Relation, which requires a second query.
        users = mgrRole.getUsers()
        users.query().get req.user.id,
        success: (obj) ->
          if obj
            
            # Add the user to the tenant ACL list. Currently, there is only 
            # one list, but this may have to be divided in the future.
            if tntRole
              tntRole.getUsers().add user
              tntRole.save()
            
            # Notify the user.
            title = property.get "thoroughfare"
            notificationACL = new Parse.ACL
            notificationACL.setReadAccess(user, true)
            notificationACL.setWriteAccess(user, true)
            new Parse.Object("Notification").save
              name: "#{className}_invitation".toLowerCase()
              text: "You have been invited to join #{title}"
              channels: [ "profiles-#{profile.id}" ]
              channel: "profiles-#{profile.id}"
              forMgr: false
              property: property
              network: network
              ACL: notificationACL
            
            # Upgrade the status
            status = if status and status is 'pending' then 'current' else 'invited'
            req.object.set "status", status

            # Add users to property ACL individually
            if status is 'current' and user
              propertyACL = property.getACL()
              propertyACL.setReadAccess user, true
              property.setACL propertyACL
              property.save()

            res.success()
              
          else
            
            # Notify the property.
            notification = new Parse.Object("Notification")
            notificationACL = new Parse.ACL
            notificationACL.setRoleReadAccess(mgrRole, true)
            notificationACL.setRoleWriteAccess(mgrRole, true)
            notification.save
              name: "tenant_inquiry"
              text: "%NAME wants to join your property."
              channels: [ "networks-#{network.id}", "properties-#{propertyId}" ]
              channel: "networks-#{network.id}"
              forMgr: true
              property: property
              network: network
              ACL: notificationACL
            
            # Give property managers access to user.
            (new Parse.Query "_User").get user.id,
            success: (user) ->
              userACL = user.getACL
              userACL.setRoleReadAccess(mgrRole, true)
              user.save ACL: userACL
                        
            # There is only one lease role, so no need to change.
            status = if status and status is 'invited' then 'current' else 'pending'
            req.object.set "status", status

            # Add users to property ACL individually
            if status is 'current' and user
              propertyACL = property.getACL()
              propertyACL.setReadAccess user, true
              property.setACL propertyACL
              property.save()

            res.success()
        error: -> res.error "bad_query"
      else res.error "no matching role"
    error: -> res.error "bad_query"
  error: -> res.error "bad_query"


# Tenant validation
Parse.Cloud.beforeSave "Manager", (req, res) ->
  
  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    req.object.unset "accessToken"
    return res.success()
    
  (new Parse.Query "Network").include('role').get req.object.get("network").id,
  success: (network) ->
    
    profile = req.object.get "profile"
    user = profile.get "user"
    status = req.object.get "status"
    mgrRole = network.get "role"
    
    # Set ACL
    unless req.object.existed()
      managerACL = new Parse.ACL
      managerACL.setRoleReadAccess mgrRole, true if mgrRole
      managerACL.setRoleWriteAccess mgrRole, true if mgrRole
      req.object.setACL managerACL
      
    # Change the status depending on who is creating the link.      
    if mgrRole
      # Check if the REQUEST user is in the role.
      # Users are in a Parse.Relation, which requires a second query.
      users = mgrRole.getUsers()
      users.query().get req.user.id,
      success: (obj) ->
        if obj
          
          # Add the user to the tenant ACL list. Currently, there is only 
          # one list, but this may have to be divided in the future.
          users.add user
          mgrRole.save()
          
          # Notify the user.
          title = network.get "title"
          notification = new Parse.Object("Notification")
          notificationACL = new Parse.ACL()
          notificationACL.setReadAccess(req.object.get("user"), true)
          notificationACL.setWriteAccess(req.object.get("user"), true)
          notification.save
            name: "network_invitation"
            text: "You have been invited to join #{title}"
            channels: [ "networks-#{network.id}" ]
            channel: "networks-#{network.id}"
            forMgr: false
            network: network
            ACL notificationACL
            
          # Upgrade the status
          status = if status and status is 'pending' then 'current' else 'invited'
          req.object.set "status", status
          res.success()
          
        else
          
          # Notify the property.
          notification = new Parse.Object("Notification")
          notificationACL = new Parse.ACL()
          notificationACL.setRoleReadAccess(mgrRole, true)
          notificationACL.setRoleWriteAccess(mgrRole, true)
          notification.save
            name: "network_inquiry"
            text: "%NAME wants to join your property."
            channels: [ "networks-#{network.id}", "properties-#{req.params.propertyId}" ]
            channel: "networks-#{network.id}"
            forMgr: true
            network: network
            ACL: notificationACL
            
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
      error: -> res.error "bad_query"
    else res.error "no matching role"
  error: -> res.error "bad_query"


# Notification tasks
Parse.Cloud.beforeSave "Notification", (req, res) ->

  (new Parse.Query "Profile").equalTo('user', req.user).first()
  .then (profile) ->
    req.object.set "profile", profile
    res.success()


# Notification tasks
Parse.Cloud.afterSave "Notification", (req) ->
  
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
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
  if !channels or channels.length is 1 then body.channel = channels[0] else body.channels = channels
  
  body = JSON.stringify body
  body_md5 = C.CryptoJS.MD5(body).toString(C.CryptoJS.enc.Hex)
  
  string_to_sign = method + "\n" + 
    addedUrl + "\n" +
    "auth_key=#{key}" + 
    "&auth_timestamp=#{timestamp}" +
    "&auth_version=#{version}" + 
    "&body_md5=#{body_md5}"
  
  signature = C.CryptoJS.HmacSHA256(string_to_sign, secret).toString(C.CryptoJS.enc.Hex)
  
  Parse.Cloud.httpRequest
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
      
  # This will only work if we can get the users.
  # 
  # # Sena an email
  # Mandrill.sendEmail
  #   message:
  #     subject: name
  #     text: text
  #     from_email: "parse@cloudcode.com"
  #     from_name: "Cloud Code"
  #     to: [{email: email, name: email}]
  #   async: true
  # ,
  #   success: (httpres) ->
  #   error: (httpres) ->
  
  # Send a push notification
  push_text = if text.indexOf("%NAME") > 0
    profile = req.object.get("profile")
    name = if profile.get("first_name") then profile.get("first_name") else profile.get("email")
    text.replace("%NAME", name)
  else 
    text
  Parse.Push.send 
    channels: channels, data: alert: push_text
  , 
    # success: -> 
    error: (error) -> 
      req.object.set "error", JSON.stringify(error)
      req.object.save()

# Search validation
Parse.Cloud.beforeSave "Search", (req, res) ->
  req.object.set "user", req.user
  res.success()

# # Task validation
# Parse.Cloud.beforeSave "Task", (req, res) ->
#   req.object.set "user", req.user
#   res.success()


# # Income validation
# Parse.Cloud.beforeSave "Income", (req, res) ->
#   req.object.set "user", req.user
#   res.success()


# # Expense validation
# Parse.Cloud.beforeSave "Expense", (req, res) ->
#   req.object.set "user", req.user
#   res.success()
