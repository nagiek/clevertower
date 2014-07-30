# Social functions
# ----------
# Used to set protected properties on Activity and Profile objects.
Parse.Cloud.define "Follow", (req, res) ->
  Parse.Cloud.useMasterKey()
  (new Parse.Query "Profile").equalTo('objectId', req.params.followee).first()
    .then (model) ->
      if model
        model.increment followersCount: +1
        profile = new Parse.Object("Profile")
        profile.id = req.params.follower
        model.relation("likers").add profile

        activityACL = new Parse.ACL
        activityACL.setReadAccess req.user.id, true
        activityACL.setWriteAccess req.user.id, true
        activityACL.setPublicReadAccess true

        notificationACL = new Parse.ACL
        notificationACL.setReadAccess model.get("user").id, true
        notificationACL.setWriteAccess model.get("user").id, true

        activity = new Parse.Object("Activity")

        name = if model.get("first_name") then model.get("first_name") else model.get("name")
        activity.set
          activity_type: "follow"
          title: "%NAME is now following #{name}"
          public: true
          likersCount: 0
          commentCount: 0
          isEvent: false
          hasAction: false
          wideAudience: false
          subject: profile
          object: model
          ACL: activityACL

        notification = new Parse.Object("Notification")
        notification.set
          text: "%NAME is now following you."
          channels: [ "profiles-#{model.id}" ]
          channel: "profiles-#{model.id}"
          name: "follow"
          forMgr: false
          withAction: false
          # TODO: invitingProfile causes notification to not save.
          subject: profile
          object: model
          # No email, as they have to exist, and email is only if they don't.
          # email: model.get("email")
          ACL: notificationACL

        Parse.Object.saveAll [model, activity, notification],
        success: -> res.success()
        error: -> res.error "model_not_saved"
      else 
        res.error "bad_query"
    , -> res.error "bad_query"

Parse.Cloud.define "Unfollow", (req, res) ->
  Parse.Cloud.useMasterKey()
  (new Parse.Query "Profile").equalTo('objectId', req.params.followee).first()
    .then (model) ->
      if model
        model.increment followersCount: -1
        profile = new Parse.Object("Profile")
        profile.id = req.params.follower
        model.relation("likers").remove profile
        model.save().then ->
          res.success()
        , -> res.error "model_not_saved"
      else 
        res.error "bad_query"
    , -> res.error "bad_query"


Parse.Cloud.define "Like", (req, res) ->
  Parse.Cloud.useMasterKey()
  (new Parse.Query "Activity").equalTo('objectId', req.params.likee).include("subject").first()
    .then (model) ->
      if model
        model.increment likersCount: +1
        profile = new Parse.Object("Profile")
        profile.id = req.params.liker
        model.relation("likers").add profile
        
        activityACL = new Parse.ACL
        activityACL.setReadAccess req.user.id, true
        activityACL.setWriteAccess req.user.id, true
        activityACL.setPublicReadAccess true

        notificationACL = new Parse.ACL
        notificationACL.setReadAccess model.get("subject").get("user").id, true
        notificationACL.setWriteAccess model.get("subject").get("user").id, true

        activity = new Parse.Object("Activity")
        if model.get("subject").id isnt profile.id
          name = if model.get("subject").get("first_name") then model.get("subject").get("first_name") else model.get("subject").get("name")
          name += "'s"

          # Notify the user if their activity has been liked
          if model.get("likersCount") is 1
            notification = new Parse.Object("Notification")
            notification.set
              text: "%NAME liked your activity."
              channels: [ "profiles-#{model.get("subject").id}" ]
              channel: "profiles-#{model.get("subject").id}"
              name: "like"
              forMgr: false
              withAction: false
              # TODO: invitingProfile causes notification to not save.
              subject: profile
              object: model.get("subject")
              # No email, as they have to exist, and email is only if they don't.
              # email: model.get("email")
              ACL: notificationACL

        else
          name = "their own"

        activity.set
          activity_type: "like"
          title: "%NAME liked #{name} activity"
          activity: model
          public: true
          likersCount: 0
          commentCount: 0
          isEvent: false
          hasAction: true
          wideAudience: false
          subject: profile
          # Subject of activity is object of our "like".
          object: model.get("subject")
          ACL: activityACL

        Parse.Object.saveAll [model, activity, notification], 
        success: -> res.success()
        error: (error) -> res.error "model_not_saved"
      else 
        res.error "bad_query"
    , -> res.error "bad_query"

Parse.Cloud.define "Unlike", (req, res) ->
  Parse.Cloud.useMasterKey()
  (new Parse.Query "Activity").equalTo('objectId', req.params.likee).first()
    .then (model) ->
      if model
        model.increment likersCount: -1
        profile = new Parse.Object("Profile")
        profile.id = req.params.liker
        model.relation("likers").remove profile
        model.save().then ->
          res.success()
        , -> res.error "model_not_saved"
      else 
        res.error "bad_query"
    , -> res.error "bad_query"




# Administrative
# ----------

# Feature a given listing.
Parse.Cloud.define "PromoteToFeatured", (req, res) ->
  Parse.Cloud.useMasterKey()
  (new Parse.Query "Listing").equalTo('objectId', req.params.objectId).first()
    .then (obj) ->
      if obj
        attrs = 
          cover: obj.get "image_profile"
          property: obj.get "property"
          rent: obj.get "rent"
          locality: obj.get "locality"
          title: obj.get "title"
        new Parse.Object("FeaturedListing").save(attrs).then -> res.success()
      else 
        res.error "bad_query"
    , -> res.error "bad_query"

# Generate Locations
Parse.Cloud.define "CreateLocations", (req, res) ->
  Parse.Cloud.useMasterKey()

  objectACL = new Parse.ACL
  objectACL.setPublicReadAccess true

  locationAttributes =
    [
      googleName: "Montreal--QC--Canada"
      isCity: true
      center: new Parse.GeoPoint(45.5,-73.566667)
    ,
      googleName: "Le-Plateau-Mont-Royal--Montreal--QC--Canada"
      isCity: false
      center: new Parse.GeoPoint(45.521646, -73.57545)
    ,
      googleName: "Toronto--ON--Canada" 
      isCity: true
      center: new Parse.GeoPoint(43.6537228,-79.373571)
    ,
      googleName: "The-Beaches--Toronto--ON--Canada" 
      isCity: false
      center: new Parse.GeoPoint(43.667266,-79.297128)
    ]
  profileAttributes =
    [
      fbID: 102184499823699
      name: "Montreal"
      bio: 'Originally called Ville-Marie, or "City of Mary", it is named after Mount Royal, the triple-peaked hill located in the heart of the city.'
      image_thumb: "/img/city/Montreal--QC--Canada.jpg"
      image_profile: "/img/city/Montreal--QC--Canada.jpg"
      image_full: "/img/city/Montreal--QC--Canada.jpg"
    ,
      fbID: 106014166105010
      name: "The Plateau-Mont-Royal"
      bio: 'The Plateau-Mont-Royal is the most densely populated borough in Canada, with 101,054 people living in an 8.1 square kilometre area.'
      image_thumb: "/img/city/Montreal--QC--Canada.jpg"
      image_profile: "/img/city/Montreal--QC--Canada.jpg"
      image_full: "/img/city/Montreal--QC--Canada.jpg"
    ,
      fbID: 110941395597405
      name: "Toronto" 
      bio: 'Canada’s most cosmopolitan city is situated on beautiful Lake Ontario, and is the cultural heart of south central Ontario and of English-speaking Canada.'
      image_thumb: "/img/city/Toronto--ON--Canada.jpg"
      image_profile: "/img/city/Toronto--ON--Canada.jpg"
      image_full: "/img/city/Toronto--ON--Canada.jpg"
    ,
      fbID: 111084918946366
      name: "The Beaches" 
      bio: 'The Beaches (also known as "The Beach") is a neighbourhood and popular tourist destination. It is located on the east side of the "Old" City of Toronto.'
      image_thumb: "/img/city/Toronto--ON--Canada.jpg"
      image_profile: "/img/city/Toronto--ON--Canada.jpg"
      image_full: "/img/city/Toronto--ON--Canada.jpg"
    ]
  locations = []

  for attrs, i in locationAttributes
    attrs.profile = new Parse.Object("Profile", profileAttributes[i])
    # ProfileACL set after
    # attrs.profile.setACL attrs.ACL = objectACL
    attrs.ACL = objectACL
    locations.push new Parse.Object("Location", attrs)

  Parse.Object.saveAll locations, 
    success: -> res.success()
    error: (error) -> res.error 

# Set Picture
# -----------
# Set a user's picture to an external URL
Parse.Cloud.define "SetPicture", (req, res) ->

  Parse.Cloud.httpRequest
    method: "GET"
    url: req.params.url
    success: (httpres) ->
      # Write the response to a buffer and save as file.
      Buffer = require('buffer').Buffer
      buf = new Buffer(httpres.buffer)      
      file = new Parse.File(req.user.getUsername() + "-picture.jpeg", base64: buf.toString('base64'))
      file.save().then( ->
        # console.error '1a'
        (new Parse.Query "Profile").equalTo('objectId', req.user.get("profile").id).first()
      , (error) ->
        # console.error '1b'
        res.error error
      ).then( (profile) ->
        # console.error '2a'
        profile.save image_thumb: file.url(), image_profile: file.url(), image_full: file.url()
      , (error) ->
        # console.error '2b'
        res.error error
      ).then( ->
        # console.error '3a'
        res.success file.url()
        # error: (error) ->
        #   res.error)
      , (error) ->
        # console.error '3b'
        res.error error
      )
    error: (error) ->
      res.error error
      # console.error("Got response: " + res.statusCode);
      # res.setEncoding('binary')
      # var imagedata = ''
      # res.on('data', function(chunk){
      #     imagedata+= chunk; 
      # });
      # res.on('end', function(){
      #     fs.writeFile(o.dest, imagedata, 'binary', cb);
      # });


# AddTenants
# ----------
# This can be called by managers or tenants.
# Can be done on either Leases or Inquiries, but always comes from an invitational perspective
# @see Tenant BeforeSave.
Parse.Cloud.define "AddTenants", (req, res) ->
  emails = req.params.emails
  className = req.params.className
  return res.error "emails_missing"  unless emails

  _ = require "underscore"
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
  # Status is always 'invited', as we are saving a lease with
  # a joined tenant, instead of being a tenant trying to join.
  # In theory this could overwrite an inquiry, but oh well.
  status = 'invited'

  # We have to switch to the Master Key, to send the invite.
  # The profile will be open, but the user (who will receive the notification)
  # will be closed.
  # 
  # Alternative is to blast out unsecured notifications.
  Parse.Cloud.useMasterKey()

  existingProfiles = []

  # (new Parse.Query Parse.User).find().then -> console.error "arguments1"; console.error arguments

  # Lease/Applicant Role
  (new Parse.Query className)
  .include('role')
  .include("property.profile")
  .include("property.role")
  .include("property.mgrRole")
  .include("property.network.role")
  .equalTo("objectId", req.params.objectId)
  .first().then (leaseOrInquiry) ->
    
    tntRole = leaseOrInquiry.get "role"
    property = leaseOrInquiry.get "property"
    propRole = property.get "role"
    mgrRole = property.get "mgrRole"
    title = property.get("profile").get("name")
    network = property.get "network"
    # Possible that the property is not part of a network.
    netRole = if network then network.get "role" else false

    # ACL for our new object
    joinClassName = if className is "Lease" then "Tenant" else "Applicant"
    joinClassACL = new Parse.ACL

    # Change the status depending on who is creating the link.
    if mgrRole or netRole
      # Check if the REQUEST user is in the role.
      # Users are in a Parse.Relation, which requires a second query.
      if mgrRole
        mgrUsers = mgrRole.getUsers()
        mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first()
      if netRole
        netUsers = netRole.getUsers() 
        netQuery = netUsers.query().equalTo("objectId", req.user.id).first()

    profileQuery = new Parse.Query("Profile").include("user").containedIn("email", emails).find()

    Parse.Promise.when(mgrQuery, netQuery, profileQuery).then( (mgrObj, netObj, profiles) ->
      # We can allow this, for tenants joining the property.
      # res.error "not_a_manager" if className is "Lease" and !(mgrObj or netObj)
      
      if tntRole
        tntRoleUsers = tntRole.getUsers() 
        joinClassACL.setRoleReadAccess tntRole, true
        joinClassACL.setRoleWriteAccess tntRole, true

      if netRole
        joinClassACL.setRoleReadAccess netRole, true
        joinClassACL.setRoleWriteAccess netRole, true

      if propRole and className is "Lease"
        propRoleUsers = propRole.getUsers() 
        # Allow the tenants to see the other tenants.
        joinClassACL.setRoleReadAccess propRole, true
        

      if mgrRole
        joinClassACL.setRoleReadAccess mgrRole, true
        joinClassACL.setRoleWriteAccess mgrRole, true

      # Set profile to be totally open. Will close once the user registers.
      profileACL = new Parse.ACL
      profileACL.setPublicReadAccess true
      profileACL.setPublicWriteAccess true

      # Keep the existing profiles for next step.
      existingProfiles = profiles
      newProfileSaves = profiles || new Array()
      profileEmails = new Array() # _.map(profiles, (profile) -> profile.get("email"))
      emailsWithoutProfile = new Array()

      for profile in profiles
        if className is "Lease"
          # Go through and add to roles for new Leases.
          user = profile.get "user"
          if user
            # Add to the tenant role.
            if tntRole then tntRoleUsers.add user
            # Security for propRoleUsers. Should only be allowed if: 
            #   1) We are a manager.
            #   2) We are trying to join and the property is set to open.
            if propRole and (mgrObj or netObj) or !netRole then propRoleUsers.add user 

        profileEmails.push profile.get "email"

      emailsWithoutProfile = _.difference emails, profileEmails 

      for email in emailsWithoutProfile
        # Add the SignUp promise to the list of things to do.
        newProfile = new Parse.Object("Profile").set
          email: email
          ACL: profileACL
        newProfileSaves.push newProfile

      Parse.Object.saveAll newProfileSaves, 
      success: (newProfiles) ->

        joinClassSaves = new Array()

        for profile in newProfiles

          # Profile exists, but user does not necessarily exist.
          user = profile.get("user")

          # Save the joinClass
          newJoinClass = new Parse.Object(joinClassName).set
            property: property
            network: network
            unit: leaseOrInquiry.get("unit")
            listing: leaseOrInquiry.get("listing")
            status: if user and user.id is req.user.id then 'current' else status
            profile: profile
            accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
            ACL: joinClassACL
          newJoinClass.set className.toLowerCase(),
            __type: "Pointer"
            className: className
            objectId: leaseOrInquiry.id
          joinClassSaves.push newJoinClass

        Parse.Object.saveAll joinClassSaves,
        success: (newJoinClasses) ->

          objsToSave = new Array()
          for joinClass in newJoinClasses

            # Profile exists, but user does not necessarily exist.
            profile = joinClass.get("profile")
            user = profile.get("user")

            # Send a notification, unless it is to us.
            unless user and user.id is req.user.id 

              notificationACL = new Parse.ACL()

              if user
                notificationACL.setReadAccess user.id, true
                notificationACL.setWriteAccess user.id, true

              else
                # Notify the user
                Mandrill.sendEmail
                  message:
                    subject: "You have been invited to try CleverTower"
                    text: "Hello World!"
                    from_email: "parse@cloudcode.com"
                    from_name: "Cloud Code"
                    to: [{email: profile.get("email"), name: profile.get("email")}]
                  async: true
                # Do nothing, but have to keep object around regardless.
                , success: (httpres) ->
                  error: (httpres) ->

              notification = new Parse.Object("Notification").set
                text: "You have been invited to join #{title}"
                channels: [ "profiles-#{profile.id}" ]
                channel: "profiles-#{profile.id}"
                name: "#{className.toLowerCase()}_invitation"
                forMgr: false
                withAction: true
                # TODO: invitingProfile causes notification to not save.
                subject: property.get("profile")
                object: profile
                email: profile.get("email")
                property: property
                network: network
                ACL: notificationACL
              notification.set joinClassName.toLowerCase(), joinClass

              objsToSave.push notification

          if className is "Lease"
            objsToSave.push propRole if propRole
            objsToSave.push tntRole if tntRole
            
          Parse.Object.saveAll objsToSave, 
          success: -> res.success leaseOrInquiry
          error: -> 
            console.error "obj_save_error"
            res.error 'obj_save_error'

        error: (error) ->
          console.error 'joinClasses_not_saved'
          res.error 'joinClasses_not_saved'

      error: (error) ->
        console.error "profiles_not_saved"
        res.error 'profiles_not_saved'

    , (error) -> 
      console.error "role_query_error"
      res.error 'role_query_error'
    )

  , (error) -> 
    console.error "bad_query"
    res.error "bad_query"

# AddManagers
# ----------
# Differences from AddTenants:
#  - managers are added to a visit-role, not full role.
#     * Reason is that the role has decision authority.
# ----------
# THIS IS ONLY FOR adding managers en masse to a network, not to add any tenant.
# @see Tenant BeforeSave.
Parse.Cloud.define "AddManagers", (req, res) ->
  emails = req.params.emails
  return res.error "emails_missing"  unless emails

  _ = require "underscore"
  Mandrill = require 'mandrill'
  Mandrill.initialize 'rE7-kYdcFOw7SxRfCfkVzQ'
  
  # We have to switch to the Master Key, to send the invite.
  # The profile will be open, but the user (who will receive the notification)
  # will be closed.
  # 
  # Alternative is to blast out unsecured notifications.
  Parse.Cloud.useMasterKey()

  # Status is always 'invited', as we are saving a lease with
  # a joined tenant, instead of being a tenant trying to join.
  # In theory this could overwrite an inquiry, but oh well.
  status = 'invited'
  (new Parse.Query "Network").include('vstRole').equalTo("objectId", req.params.networkId).first()
  .then( (network) ->
      
    vstRole = network.get "vstRole"
    title = network.get "title"

    joinClassName = "Manager"
    joinClassACL = new Parse.ACL
    joinClassACL.setRoleRoleAccess netRole, true
    joinClassACL.setRoleWriteAccess netRole, true

    # Create joinClasses outside the when->then scope, to return it later.
    joinClasses = undefined
    
    vstRoleUsers = vstRole.getUsers()

    # Create the joinClass.
    # Query for the profile and include the user to add to roles
    (new Parse.Query "Profile").include("user").containedIn("email", emails).find()

  , -> res.error "bad_query"
  ).then((profiles) ->

    # Set profile to be totally open. Will close once the user registers.
    profileACL = new Parse.ACL
    profileACL.setPublicReadAccess true
    profileACL.setPublicWriteAccess true

    newProfileSaves = new Array()

    for email in emails
      foundProfile = false
      foundProfile = _.find profiles, (profile) -> return profile if email is profile.get "email"

      if foundProfile then newProfileSaves.push foundProfile
      else
        # Add the SignUp promise to the list of things to do.
        newProfile = new Parse.Object("Profile").set
          email: email
          ACL: profileACL
        newProfileSaves.push newProfile

    Parse.Object.saveAll newProfileSaves,
    success: (newProfiles) ->
      joinClassSaves = new Array()
      for profile in newProfiles

        # Profile exists, but user does not necessarily exist.
        user = profile.get("user")

        myJoinClassACL = joinClassACL
        if user    
          myJoinClassACL.setRoleAccess user, true
          myJoinClassACL.setReadAccess user.id, true

        # Save the joinClass
        newJoinClass = new Parse.Object(joinClassName).set
          network: network
          status: if user and user.id is req.user.id then 'current' else status
          profile: profile
          accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
          ACL: myJoinClassACL

        joinClassSaves.push newJoinClass

      Parse.Object.saveAll joinClassSaves,
      success: (joinClasses) ->

        objsToSave = new Array(vstRole)

        for joinClass in joinClasses

          # Profile exists, but user does not necessarily exist.
          profile = joinClass.get("profile")
          user = profile.get("user")

          # Send a notification, unless it is to us.
          unless user and user.id is req.user.id 

            notificationACL = new Parse.ACL()

            if user
              notificationACL.setReadAccess user.id, true
              notificationACL.setReadAccess user.id, true

              vstRoleUsers.add user

            else
              # Notify the user
              Mandrill.sendEmail
                message:
                  subject: "You have been invited to try CleverTower"
                  text: "Hello World!"
                  from_email: "parse@cloudcode.com"
                  from_name: "Cloud Code"
                  to: [{email: profile.get("email"), name: profile.get("email")}]
                async: true
              # Do nothing, but have to keep object around regardless.
              , success: (httpres) ->
                error: (httpres) ->

            notification = new Parse.Object("Notification").set
              text: "You have been invited to join #{title}"
              channels: [ "profiles-#{profile.id}" ]
              channel: "profiles-#{profile.id}"
              name: "network_invitation"
              # Profile is not a manager yet, therefore forMgr: false
              forMgr: false
              withAction: true
              # TODO: invitingProfile causes notification to not save.
              subject: network.get("profile")
              object: profile
              email: email
              network: network
              manager: joinClass
              ACL: notificationACL

            objsToSave.push notification

        Parse.Object.saveAll objsToSave,
        success: -> res.success joinClasses
        error: (error) -> res.error 'save_error'

      error: (error) -> res.error 'profiles_not_saved'
      
    error: (error) -> res.error 'joinClasses_not_saved'

  , (error) -> res.error "bad_query"
  )

# User validation
Parse.Cloud.beforeSave "Profile", (req, res) ->
  
  # email = req.object.get "email"
  # return res.error 'missing_username' if email is ''
  # return res.error 'invalid_email_format' unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test email
  
  req.object.set "createdBy", req.user unless req.object.existed()
  res.success()


# User before save
Parse.Cloud.beforeSave Parse.User, (req, res) ->

  return res.success() if req.object.existed()
  
  email = req.object.get "email"
  
  # Map the user to the profile, if any.
  # Make sure we are not taking an existing profile.
  (new Parse.Query "Profile").equalTo('email', email).doesNotExist("property").doesNotExist("location").doesNotExist("user").first()
  .then (profile) ->
    
    # Get all pre-exising profile things
    if profile 
      req.object.set "profile", profile
      res.success()

    else
      profile = new Parse.Object("Profile")
      profile.save(email: email).then ->
        req.object.set "profile", profile
        res.success()
      , -> res.error "profile_not_saved"


  , ->
    res.error "no_profile"

# User after save
Parse.Cloud.afterSave Parse.User, (req) ->

  return if req.object.existed() or !req.object.get("profile")
   
  # Map the user to the profile, if any.
  (new Parse.Query "Profile").get req.object.get("profile").id, 
  success: (profile) ->

    # There's no chance the profile has a user...
    unless profile.get("user")
      # Create a new ACL, as the existing one is set to public/public.
      # We will add to the ACL later.
      profileACL = new Parse.ACL()
      profileACL.setPublicReadAccess true
      profileACL.setReadAccess req.object, true
      profileACL.setWriteAccess req.object, true

      profile.save 
        user: req.object
        ACL: profileACL

    # Use the master key
    Parse.Cloud.useMasterKey()

    # Q: Why are we doing this? They haven't confirmed yet?
    # A: We are doing this because if a relation exists, the user must have been invited.
    #    When we invite someone we add them to the role to give them access 
    #    to what they are going to be a part of. Therefore mustwe add them.
    
    # Include the user into any properties they have been invited to.
    managerQuery = (new Parse.Query "Manager").include('network.role').equalTo('profile', profile).find()
    tenantQuery = (new Parse.Query "Tenant").include('property.role').include('lease.role').equalTo('profile', profile).find()
    notifQuery = (new Parse.Query "Notification").equalTo('channel', "profiles-#{profile.id}").find()

    Parse.Promise.when(managerQuery, tenantQuery, notifQuery)
    .then (managers, tenants, notifs) ->
      if managers
        for manager in managers
          managerACL = manager.getACL()
          managerACL.setReadAccess req.object, true
          managerACL.setWriteAccess req.object, true
          manager.setACL managerACL
          manager.save()

          vstRole = manager.get("network").get("vstRole")
          if vstRole
            vstRole.getUsers().add req.object
            vstRole.save()
      if tenants
        for tenant in tenants
          tntRole = tenant.get("lease").get("role")
          propRole = tenant.get("property").get("role")
          if tntRole
            tntRole.getUsers().add req.object
            tntRole.save()
          if propRole
            propRole.getUsers().add req.object
            propRole.save()
      if notifs
        for notif in notifs
          notifACL = notif.getACL()
          notifACL.setReadAccess req.object, true
          notifACL.setWriteAccess req.object, true
          notif.save
            # user: req.object
            ACL: notifACL

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
    
    unless req.object.existed()
    
      networkACL = new Parse.ACL()
      
      # Parse can only handle one role for now...    
      # Role lists
      randomId = ""
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
      randomId += possible.charAt Math.floor(Math.random() * possible.length) for [1...16]
      current = "mgr-current-" + randomId
      visit = "mgr-possible-" + randomId

      # Set to be open, originally.
      req.object.set "public", true
      networkACL.setPublicReadAccess true

      # Let members see and add other members.
      networkACL.setRoleReadAccess current, true
      networkACL.setRoleWriteAccess current, true

      # Let potential members see the network
      networkACL.setRoleReadAccess visit, true
      req.object.setACL networkACL
      
      # Create new role (API not chainable)
      role = new Parse.Role(current, networkACL)
      vstRole = new Parse.Role(visit, networkACL)
      role.getUsers().add(req.user)
      Parse.Object.saveAll [role, vstRole], 
      success: ->
        req.object.set "role", role
        req.object.set "vstRole", vstRole
        res.success()
      errror: -> res.error "role_error"

    else
      isPublic = req.object.get "public"
      networkACL = req.object.getACL()
      if networkACL.getPublicReadAccess() isnt isPublic
        networkACL.setPublicReadAccess(isPublic)
        req.object.setACL networkACL
      res.success()
      
  , ->
    res.error "bad_query"


# Network after save
Parse.Cloud.afterSave "Network", (req) ->
  unless req.object.existed()

    # Since the user is by-definition accepted, use the same ACL.
    managerACL = req.object.getACL()
    managerACL.setPublicReadAccess false

    new Parse.Object("Manager").save
      network: req.object
      status: 'current'
      admin: true
      profile: req.user.get "profile"
      accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
      ACL: managerACL
      
    # Save a convenient reference to the network.
    objsToSave = []
    objsToSave.push req.user.set("network", req.object)
    if req.user.get("property") then objsToSave.push req.user.get("property").set("network", req.object)
    if req.user.get("unit") then objsToSave.push req.user.get("unit").set("network", req.object)
    if req.user.get("lease") then objsToSave.push req.user.get("lease").set("network", req.object)

    Parse.Object.saveAll objsToSave


# Property validation
Parse.Cloud.beforeSave "Property", (req, res) ->
    
  unless req.object.get("center") 
    # Invalid address
    return res.error 'invalid_address'
  else unless ( 
    req.object.get("thoroughfare"            ) and # is '' or 
    req.object.get("locality"                    ) and # is '' or
      ( req.object.get("administrative_area_level_1" ) or
        req.object.get("administrative_area_level_2" ) ) and # is '' or
    req.object.get("country"                     ) and # is '' or
    req.object.get("postal_code"                 )     # is ''
  )
    # Insufficient data
    return res.error 'insufficient_data'

  # Set a proxy center for fake addresses.
  if req.object.get "approx"
    req.object.set "offset", 
      lat: Math.floor Math.random() * 100
      lng: Math.floor Math.random() * 100
  else
    req.object.set "offset", 
      # 50 = no offset
      lat: 50
      lng: 50
  
  unless req.object.existed()

    # TODO: Special transfer code if it was previously NOT part of a network and has now been transferred.
    if req.object.get("network")
      (new Parse.Query "Network").include("role").get req.object.get("network").id,
      success : (network) ->

        netRole = network.get "role"

        # Role lists
        randomId = ""
        possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        randomId += possible.charAt Math.floor(Math.random() * possible.length) for [1...16]
        current = "prop-current-" + randomId
        mgr = "prop-mgr-" + randomId

        # Give tenants access to read the property, and managers to read/write
        roleACL = network.getACL()
        roleACL.setPublicReadAccess false
        roleACL.setRoleReadAccess current, true
        roleACL.setRoleWriteAccess mgr, true
        roleACL.setRoleReadAccess mgr, true
        if netRole
          roleACL.setRoleWriteAccess netRole, true 
          roleACL.setRoleReadAccess netRole, true

        # Create new role (API not chainable)
        # Prepare a role for tenants
        role = new Parse.Role(current, roleACL)
        mgrRole = new Parse.Role(mgr, roleACL)

        objsToSave = [role, mgrRole]
        unless req.object.get("profile") then objsToSave.unshift new Parse.Object("Profile").set("name", req.object.get("thoroughfare"))

        # Create profile
        Parse.Object.saveAll objsToSave,
        success: (list) -> 

          # First item on our list.
          profile = list[0]

          # Set the property to public.
          propertyACL = roleACL

          # Set to be open, originally.
          propertyACL.setPublicReadAccess true

          req.object.set
            public: true
            user: req.user
            # role: savedRole
            # mgrRole: savedMgrRole
            role: role
            mgrRole: mgrRole
            network: network
            ACL: propertyACL

          unless req.object.get("profile") then req.object.set "profile", profile

          res.success()
        error: -> res.error "role_error"
      error : -> res.error 'bad_query'
    else

      # Role lists
      randomId = ""
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
      randomId += possible.charAt Math.floor(Math.random() * possible.length) for [1...16]
      current = "prop-current-" + randomId
      mgr = "prop-mgr-" + randomId

      # Give tenants access to read the property, and managers to read/write
      roleACL = new Parse.ACL
      roleACL.setRoleReadAccess current, true
      roleACL.setRoleWriteAccess mgr, true
      roleACL.setRoleReadAccess mgr, true

      # Create new role (API not chainable)
      # Prepare a role for tenants
      role = new Parse.Role(current, roleACL)
      mgrRole = new Parse.Role(mgr, roleACL)
      
      # Add the tenant to his new kingdon.
      role.getUsers().add req.user
      mgrRole.getUsers().add req.user

      objsToSave = [role, mgrRole]

      unless req.object.get("profile") then objsToSave.unshift new Parse.Object("Profile").set(name: req.object.get("thoroughfare"), ACL: propertyACL)

      # Create profile
      Parse.Object.saveAll objsToSave,
      success: (list) -> 
        
        # First item on our list.
        profile = list[0]

        # Set the property to public.
        propertyACL = roleACL
        propertyACL.setPublicReadAccess true

        req.object.set
          public: true
          user: req.user
          role: role
          mgrRole: mgrRole
          ACL: propertyACL

        unless req.object.get("profile") then req.object.set "profile", profile

        res.success()
      error: -> res.error "role_error"
      
  else
    isPublic = req.object.get "public"
    propertyACL = req.object.getACL()
    if propertyACL.getPublicReadAccess() isnt isPublic

      propertyACL.setPublicReadAccess(isPublic)
      req.object.setACL propertyACL

      objsToSave = []
      objsToSave.push req.object.get("profile").save(ACL: propertyACL)

      # Listings can only be public if the property is public
      (new Parse.Query "Listing").equalTo('property', req.object).find()
      .then (objs) ->
        if objs
          objsToSave = new Array
          for l in objs
            if l.get "public" isnt isPublic
              listingACL = l.getACL()
              listingACL.setPublicReadAccess isPublic
              l.set
                public: isPublic
                ACL: listingACL 
              objsToSave.push l

        Parse.Object.saveAll objsToSave,
        success: -> res.success()
        error: -> res.error "bad_save"
      , -> res.error "bad_query"
    else res.success()


# Property After Save
Parse.Cloud.afterSave "Property", (req) ->

  return if req.object.existed()

  # Map the property to the profile, if any.
  (new Parse.Query "Profile").get req.object.get("profile").id, 
  success: (profile) -> profile.save(property: req.object, ACL: req.object.getACL())


# Property After Save
Parse.Cloud.afterSave "Location", (req) ->

  return if req.object.existed()

  # Map the property to the profile, if any.
  (new Parse.Query "Profile").get req.object.get("profile").id, 
  success: (profile) -> profile.save(location: req.object, ACL: req.object.getACL())


# Unit validation
Parse.Cloud.beforeSave "Unit", (req, res) ->

  # Allow no property, as one will not yet be assigned 
  # if a tenant is creating a property/lease combo.
  return res.error 'no_property' unless req.object.get "property"
  return res.error 'no_title' unless req.object.get "title"
  
  return res.success() if req.object.existed()

  # Gain access to the network.
  Parse.Cloud.useMasterKey()

  # if req.object.get("property")
  (new Parse.Query "Property").get req.object.get("property").id,
  success: (property) -> 

    # Base the ACL off the property ACL. 
    # Do not use the network as it may not exist.
    propertyACL = property.getACL()

    propertyACL.setPublicReadAccess false

    # Add write access to the unit for the user if the user is
    # adding it to the property, and he is not part of the network.
    # 
    # This could be better and check the role, but... yeah...
    # 
    # ACL will get extra permissions if there is an activeLease.
    unless property.get("network") and property.get("network") is req.user.get("network")
      propertyACL.setReadAccess req.user.id, true
      propertyACL.setWriteAccess req.user.id, true

    req.object.set
      user: req.user
      property: property
      network: property.get "network"
      ACL: propertyACL
    res.success()
  error: -> res.error "bad_query"


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

  (new Parse.Query("Listing")).include('property.mgrRole').include('network.role').get listing.id,
  success: (obj) ->

    property = obj.get("property")
    mgrRole = property.get("mgrRole") 
    network = obj.get("network")
    netRole = network.get("role") if network

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
    channels = [ "properties-#{property.id}" ]
    if network
      notificationACL.setRoleReadAccess netRole, true
      notificationACL.setRoleWriteAccess netRole, true
      channels.push "networks-#{network.id}"
    if mgrRole
      notificationACL.setRoleReadAccess mgrRole, true
      notificationACL.setRoleWriteAccess mgrRole, true
    notificationACL.setWriteAccess req.user.id, true

    notification.save
      name: "new_inquiry"
      text: "#{name} wants to join your property."
      channels: channels
      channel: "properties-#{property.id}"
      forMgr: true
      withAction: false
      property: property
      subject: req.user.get("profile")
      object: property.get("profile")
      network: network
      ACL: notificationACL
      
    # Give tenants access to read the lease, and managers to read/write
    leaseACL = new Parse.ACL
    leaseACL.setReadAccess req.user.id, true
    leaseACL.setWriteAccess req.user.id, true
    if network
      leaseACL.setRoleWriteAccess netRole, true
      leaseACL.setRoleReadAccess netRole, true
    if mgrRole
      leaseACL.setRoleReadAccess mgrRole, true
      leaseACL.setRoleWriteAccess mgrRole, true
    req.object.setACL leaseACL
    
    res.success()

  error: -> res.error "bad_query"


# Inquiry After Save
Parse.Cloud.afterSave "Inquiry", (req) ->
  Parse.Cloud.run "AddTenants", {
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
  unit_date_query = (new Parse.Query("Lease")).equalTo("unit", req.object.get("unit"))
  if existed then unit_date_query.notEqualTo "objectId", req.object.id
  unit_date_query.find()
  .then (objs) ->
    if objs 
      for obj in objs
        sd = obj.get "start_date"
        if start_date <= sd and sd <= end_date then return res.error "#{obj.id}:overlapping_dates"
        ed = obj.get "end_date"
        if start_date <= ed and ed <= end_date then return res.error "#{obj.id}:overlapping_dates"

    # Move the emails to it's own process category.
    emails = req.object.get("emails") || []
    
    # Add the user if the lease is new and not for the network
    emails.push req.user.getEmail() unless existed or req.object.get("forNetwork")

    req.object.set "emailsToProcess", emails
    req.object.unset "emails"

    return res.success() if existed

    # Have to use the master key to check the role.
    Parse.Cloud.useMasterKey()
    
    (new Parse.Query "Property")
    .include('profile')
    .include('role')
    .include('mgrRole')
    .include('network.role')
    .get req.object.get("property").id,
    success: (property) ->
      network = property.get "network"
      mgrRole = property.get "mgrRole"
      propRole = property.get "role"

      # Set default attributes
      req.object.set 
        user: req.user
        confirmed: false
        property: property
        network: network

      # Role lists
      randomId = ""
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
      randomId += possible.charAt Math.floor(Math.random() * possible.length) for [1...16]
      current = "tnt-current-" + randomId

      # Give tenants access to read the property, and managers to read/write
      leaseACL = new Parse.ACL()
      # leaseACL = property.getACL()
      # Never let the lease be publicly visible
      leaseACL.setPublicReadAccess false

      # Let the tenants read/write the lease. 
      # If we don't want the the tenants to make changes, we can catch the attributes in the beforesave.
      leaseACL.setRoleReadAccess current, true
      leaseACL.setRoleWriteAccess current, true

      if mgrRole
        leaseACL.setRoleReadAccess mgrRole, true
        leaseACL.setRoleWriteAccess mgrRole, true

      # Let managers edit the lease.
      if network
        netRole = network.get("role") 
        return res.error "role_missing" unless netRole
        leaseACL.setRoleReadAccess netRole, true
        leaseACL.setRoleWriteAccess netRole, true

      req.object.setACL leaseACL

      # Send a notification to the property if we are joining.
      # 
      # Instead of going through the hassle of checking the roles,
      # we can simplify and just compare if the property and lease were 
      # created by the same person.
      # --------

      objsToSave = []

      unless property.get("user").id is req.user.id and req.object.get("forNetwork")
        channels = ["properties-#{property.id}"]
        notificationACL = new Parse.ACL
        notificationACL.setRoleReadAccess mgrRole, true
        notificationACL.setRoleWriteAccess mgrRole, true
        if network
          notificationACL.setRoleReadAccess netRole, true
          notificationACL.setRoleWriteAccess netRole, true
          channels.push "networks-#{network.id}" 
        notification = new Parse.Object("Notification").set
          name: "lease_join"
          text: "New tenants have joined #{property.get("profile").get("name")}"
          channels: channels
          channel: "property-#{property.id}"
          forMgr: true
          withAction: false
          subject: req.user.get("profile")
          object: property.get("profile")
          property: property
          network: network
          ACL: notificationACL
        objsToSave.push notification

      # Create new role (API not chainable)
      # Prepare a role for tenants
      role = new Parse.Role(current, leaseACL)
      # This is done via the AddTenants function.
      # role.getUsers().add req.user unless req.object.get "forNetwork"
      objsToSave.push role

      Parse.Object.saveAll objsToSave, 
      success: -> 
        req.object.set "role", role
        res.success()
      error: (error) -> res.error "role_error"

    error: -> res.error "bad_query"
  , -> res.error "bad_query"


# Lease After Save
Parse.Cloud.afterSave "Lease", (req) ->
  
  # Set active lease on unit
  today       = new Date
  start_date  = req.object.get "start_date"
  end_date    = req.object.get "end_date"

  unless req.object.get "forNetwork"
    vars = 
      property: req.object.get "property"
      unit: req.object.get "unit"
      lease: req.object
    req.user.save(vars)

  # Adjust the unit if the lease is active, or if there is
  # the chance that the unit is new and needs adjusting.
  active = start_date < today and today < end_date
  if active or !req.object.existed()
    (new Parse.Query "Unit").get req.object.get("unit").id,
    success: (unit) ->

      unitACL = req.object.getACL()

      if active
        unit.set "activeLease", req.object

        _ = require "underscore"
        unitACLList = unitACL.toJSON()
        keys = _.keys unitACLList
        role = _.find keys, (key) -> key.indexOf "role:tnt-current" is 0

        if role 
          # Remove the "role:" from the name.
          role = role.substr(5)
          unitACL.setRoleReadAccess role, true
          unitACL.setRoleWriteAccess role, true

      # We do not have an ACL if we do not have a property (like when a
      # tenant creates a lease/property combo). Therefore set the ACL
      # from the lease.
      noProperty = !unit.get("property")
      if noProperty then unit.set
        ACL: unitACL
        property: req.object.get("property")

      # Save only if we have to.
      unit.save() if active or noProperty

  emails = req.object.get "emailsToProcess"
  if emails and emails.length > 0
    Parse.Cloud.run "AddTenants", # {
      objectId: req.object.id
      emails: emails
      className: "Lease"
  # },
  # success: (res) ->
  # error: (res) ->


# Listing validation
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

  (new Parse.Query "Unit").include('property.mgrRole').include('property.network.role').get req.object.get("unit").id,
  success: (unit) ->

    property = unit.get "property"
    propertyIsPublic = property.getACL().getPublicReadAccess()

    unless req.object.existed()
      network = property.get "network"

      # Give public access to read the lease, and managers to read/write
      listingACL = new Parse.ACL()
      listingACL.setPublicReadAccess propertyIsPublic
      if network
        netRole = network.get "role"
        listingACL.setRoleWriteAccess netRole, true
        listingACL.setRoleReadAccess netRole, true
      
      mgrRole = property.get "mgrRole"
      if mgrRole
        listingACL.setRoleWriteAccess mgrRole, true
        listingACL.setRoleReadAccess mgrRole, true

      # Let the user modify their own listing, if 
      listingACL.setWriteAccess req.user.id, true
      listingACL.setReadAccess req.user.id, true

      req.object.set 
        # Update with the property in case it wasn't set.
        property: property
        # Update the listing with the location
        locality: property.get "locality"
        center: property.get "center"
        # Update the listing with the Unit characteristics
        bedrooms: unit.get "bedrooms"
        bathrooms: unit.get "bathrooms"
        square_feet: unit.get "square_feet"
        # Save user
        user: req.user
        # Save public
        public: propertyIsPublic
        ACL: listingACL

      res.success()

    else

      isPublic = req.object.get "public"

      # A listing can only be public if the property is public.
      if propertyIsPublic is false and isPublic is true
        listingACL = req.object.getACL()
        listingACL.setPublicReadAccess false
        req.object.set
          public: false
          ACL: listingACL
      res.success()


# Listing validation
Parse.Cloud.afterSave "Listing", (req) ->

  if req.object.existed() and req.object.get "activity"

    (new Parse.Query "Activity").get req.object.get("activity").id,

    success: (activity) ->

      if req.object.get "public"
        activity.save
          rent: req.object.get "rent"
          title: req.object.get "title"
      else 
        activity.destroy()


# Tenant validation
# 
# Legend:
#   user means req.user (decider)
#   account means target (object)
# 
# Paths:
# 
#                                / target had previously asked to join
#              user is manager
#         /                      \ target had not previously asked to join
#        /
#   start
#        \
#         \                      / target was previously invited
#            user is not manager  
#                                \ target was not previously invited
#                       
# 

Parse.Cloud.beforeSave "Tenant", (req, res) ->

  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    # We can use unset here.
    req.object.unset "accessToken"
    return res.success()

  # Have to use the master key to check the role.
  Parse.Cloud.useMasterKey()

  (new Parse.Query "Lease")
  .include('role')
  .include("property.profile")
  .include("property.mgrRole")
  .include("property.role")
  .include("property.network.role")
  .get req.object.get("lease").id,
  success: (lease) ->
    property = lease.get("property")

    # INSECURE.
    # Temp workaround until req.object.original lands.
    status = req.object.get "status"
    newStatus = req.object.get "newStatus"

    tntRole = lease.get "role"
    propRole = property.get "role"
    mgrRole = property.get "mgrRole"
    network = property.get "network"
    netRole = network.get "role" if network
        
    # Change the status depending on who is creating the link.
    if mgrRole or netRole
      # Check if the REQUEST user is in the role.
      # Users are in a Parse.Relation, which requires a second query.
      if mgrRole
        mgrUsers = mgrRole.getUsers()
        mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first()
      if netRole
        netUsers = netRole.getUsers() 
        netQuery = netUsers.query().equalTo("objectId", req.user.id).first()

      profileQuery = (new Parse.Query "Profile").include("user").equalTo("objectId", req.object.get("profile").id).first()

      Parse.Promise.when(mgrQuery, netQuery, profileQuery)
      .then( (mgrObj, netObj, profile) ->
        objsToSave = []
        user = profile.get "user"

        # Set ACL
        unless req.object.existed()

          tenantACL = new Parse.ACL
          tenantACL.setRoleReadAccess propRole, true if propRole

          # Let tenants adjust their own status.
          # Note that we use a beforeSave to catch unauthorized status updates.
          if tntRole
            tenantACL.setRoleReadAccess tntRole, true 
            tenantACL.setRoleWriteAccess tntRole, true

          # Let managers adjust the status
          if mgrRole
            tenantACL.setRoleReadAccess mgrRole, true
            tenantACL.setRoleWriteAccess mgrRole, true
          if netRole
            tenantACL.setRoleReadAccess netRole, true
            tenantACL.setRoleWriteAccess netRole, true

          req.object.set 
            property: property
            network: network
            unit: lease.get "unit"
            lease: lease
            ACL: tenantACL

        if mgrObj or netObj
          
          # Add the user to the tenant ACL list (lease AND property). 
          if user
            if tntRole 
              tntRole.getUsers().add user
              objsToSave.push tntRole
            if propRole
              propRole.getUsers().add user
              objsToSave.push propRole

          # Upgrade the status
          if req.object.existed() and status and status is 'pending' and newStatus and newStatus is 'current'

            # Made it! No need to add tenant to role as they are already there.

            if user
              user.set
                property: property 
                unit: req.object.get "unit"
                lease: req.object.get "lease"
              objsToSave.push user

            # Create activity
            activity = new Parse.Object("Activity")
            activityACL = new Parse.ACL
            activityACL.setRoleReadAccess netRole, true if netRole
            activityACL.setRoleReadAccess mgrRole, true if mgrRole
            activityACL.setRoleReadAccess propRole, true if propRole

            activity.set
              activity_type: "new_tenant"
              public: false
              center: property.get "center"
              # lease: req.object.get "lease"
              # tenant: req.object
              unit: req.object.get "unit"
              property: property
              network: network
              subject: profile
              object: property.get("profile")
              accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
              ACL: activityACL
            objsToSave.push activity

          else
            newStatus = 'invited'

            # Notify the user.
            title = property.get("profile").get "name"
            notificationACL = new Parse.ACL
            notificationACL.setReadAccess user.id, true
            notificationACL.setReadAccess user.id, true
            notification = new Parse.Object("Notification").set
              name: "lease_invitation"
              text: "You have been invited to join #{title}"
              channels: [ "profiles-#{profile.id}" ]
              channel: "profiles-#{profile.id}"
              forMgr: false
              withAction: true
              subject: property.get("profile")
              object: profile
              property: property
              network: network
              ACL: notificationACL
            objsToSave.push notification
          
          req.object.set "status", newStatus
              
        else

          # Give property managers access to user.
          if mgrRole or netRole or propRole
            # This will fail if mgrRole or netRole doesn't exist.
            # unless profileACL.getRoleReadAccess(mgrRole) and profileACL.getRoleReadAccess(netRole)
            profileACL = profile.getACL()
            profileACL.setRoleReadAccess propRole, true if propRole
            profileACL.setRoleReadAccess mgrRole, true if mgrRole
            profileACL.setRoleReadAccess netRole, true if netRole
            profile.setACL profileACL
            objsToSave.push profile

          if req.object.existed() and status and status is 'invited' and newStatus and newStatus is 'current'

            if user
              user.set
                property: property 
                unit: req.object.get "unit"
                lease: req.object.get "lease"
              objsToSave.push user

            # Create activity
            activity = new Parse.Object("Activity")
            activityACL = new Parse.ACL
            activityACL.setRoleReadAccess mgrRole, true if mgrRole
            activityACL.setRoleReadAccess netRole, true if netRole
            activityACL.setRoleReadAccess propRole, true if propRole

            activity.set
              activity_type: "new_tenant"
              public: false
              center: property.get "center"
              # tenant: req.object
              # lease: lease
              unit: lease.get "unit"
              property: property
              network: network
              subject: property.get("profile")
              object: profile
              accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb"
              ACL: activityACL
            objsToSave.push activity

          else

            channels = ["properties-#{propertyId}"]
            if network then channels.push "networks-#{network.id}"
            newStatus = 'pending'
            # Notify the property.
            notification = new Parse.Object("Notification")
            notificationACL = new Parse.ACL
            if mgrRole
              notificationACL.setRoleReadAccess mgrRole, true 
              notificationACL.setRoleWriteAccess mgrRole, true
            if netRole
              notificationACL.setRoleReadAccess netRole, true 
              notificationACL.setRoleWriteAccess netRole, true

            notification.set
              name: "tenant_inquiry"
              text: "%NAME wants to join your property."
              channels: channels
              channel: "properties-#{propertyId}"
              forMgr: true
              withAction: true
              subject: profile
              object: property.get("profile")
              property: property
              network: network
              ACL: notificationACL
            objsToSave.push notification
          
          req.object.set "status", newStatus

        Parse.Object.saveAll objsToSave, 
        success: -> res.success() # res.success network
        error: (error) -> res.error "bad_save"
      , -> res.error "bad_query"
      ) 
    else res.error "no matching role"
  error: -> res.error "bad_query"

# Concerige validation
# 
# Legend:
#   user means req.user (decider)
#   account means target (object)
# 
# Paths:
# 
#                                     / user is propManager --> approve if exists, convert to network
#            property has no network
#         /                           \ user is joining and has network --> send notification
#        /
#   start
#        \
#         \                          
#             property has network  --> return
#                       
# 

Parse.Cloud.beforeSave "Concerige", (req, res) ->

  # Have to use the master key to check the role.
  Parse.Cloud.useMasterKey()

  (new Parse.Query "Property")
  .include('role')
  .get req.object.get("property").include("profile").include("network.role").id,
  success: (property) ->

    # INSECURE.
    # Temp workaround until req.object.original lands.
    status = req.object.get "status"
    newStatus = req.object.get "newStatus"

    mgrRole = property.get "mgrRole"
    network = property.get "network"
    netRole = network.get "role" 
        
    # Change the status depending on who is creating the link.
    # Users are in a Parse.Relation, which requires a second query.
    mgrUsers = mgrRole.getUsers() 
    mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first()

    netUsers = netRole.getUsers() 
    netQuery = netUsers.query().equalTo("objectId", req.user.id).first()

    profileQuery = (new Parse.Query "Profile").include("user").equalTo("objectId", req.object.get("profile").id).first()

    Parse.Promise.when(mgrQuery, profileQuery, netQuery)
    .then( (mgrObj, profile, netObj) ->
      objsToSave = []
      user = profile.get "user"

      # Set ACL
      unless req.object.existed()

        # Let managers adjust the status
        # Note that we use a beforeSave to catch unauthorized status updates.

        concerigeACL = new Parse.ACL
        concerigeACL.setRoleReadAccess mgrRole, true
        concerigeACL.setRoleWriteAccess mgrRole, true
        concerigeACL.setReadAccess netRole, true
        concerigeACL.setWriteAccess netRole, true
        req.object.setACL concerigeACL

      # Check if the REQUEST user is in the role.
      if mgrObj

        # Upgrade the status
        if req.object.existed() and status and status is 'pending' and newStatus and newStatus is 'current'

          # Made it!

          concerigeACL = req.object.getACL()
          concerigeACL.setRoleReadAccess netRole, true
          concerigeACL.setRoleWriteAccess netRole, true

          property.set
            network: network
            ACL: concerigeACL
          objsToSave.push property

        else
          newStatus = 'invited'

          # Notify the user.
          title = property.get("profile").get "name"
          notificationACL = new Parse.ACL
          notificationACL.setRoleReadAccess netRole, true
          notificationACL.setRoleWriteAccess netRole, true
          notification = new Parse.Object("Notification").save
            name: "property_invitation"
            text: "You have been requested to manage #{title}"
            channels: [ "networks-#{network.id}" ]
            channel: "networks-#{network.id}"
            forMgr: true
            withAction: true
            subject: req.user.get("profile")
            object: network.get("profile")
            network: network
            ACL: notificationACL
          objsToSave.push notification
        
        req.object.set "status", newStatus
            
      else

        # User is not a manager. User better be part of the network
        return res.error() unless netObj

        profileACL = profile.getACL()
        profileACL.setRoleReadAccess mgrRole, true
        profile.setACL profileACL
        objsToSave.push profile

        if req.object.existed() and status and status is 'invited' and newStatus and newStatus is 'current'

          # Add the user to the managerACL list
          concerigeACL = req.object.getACL()
          concerigeACL.setRoleReadAccess netRole, true
          concerigeACL.setRoleWriteAccess netRole, true

          property.set 
            network: network
            ACL: concerigeACL
          objsToSave.push property

        else
          newStatus = 'pending'
          # Notify the network.
          title = network.get "title"
          notificationACL = new Parse.ACL
          notificationACL.setRoleReadAccess mgrRole, true 
          notificationACL.setRoleWriteAccess mgrRole, true

          notification = new Parse.Object("Notification").save
            name: "network_inquiry"
            text: "#{title} wants to manage your property"
            channels: [ "properties-#{property.id}" ]
            channel: "properties-#{property.id}"
            forMgr: false
            withAction: true
            subject: req.user.get("profile")
            object: network.get("profile")
            network: network
            ACL: notificationACL
          objsToSave.push notification 
        
        req.object.set "status", newStatus

      Parse.Object.saveAll objsToSave, 
      success: -> res.success() # res.success network
      error: (error) -> res.error "bad_save"
    , -> res.error "bad_query"
    ) 
  error: -> res.error "bad_query"

# Manager validation
# 
# Legend:
#   user means req.user (decider)
#   account means target (object)
# 
# Paths:
# 
#                                / target had previously asked to join
#              user is manager
#         /                      \ target had not previously asked to join
#        /
#   start
#        \
#         \                      / target was previously invited
#            user is not manager  
#                                \ target was not previously invited
#                       
# 

Parse.Cloud.beforeSave "Manager", (req, res) ->

  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    # We can use unset here.
    req.object.unset "accessToken"
    return res.success()

  # Have to use the master key to check the role.
  Parse.Cloud.useMasterKey()

  (new Parse.Query "Network")
  .include('role')
  .include('vstRole')
  .get req.object.get("network").id,
  success: (network) ->

    # INSECURE.
    # Temp workaround until req.object.original lands.
    status = req.object.get "status"
    newStatus = req.object.get "newStatus"

    netRole = network.get "role"
    vstRole = network.get "vstRole"
        
    # Change the status depending on who is creating the link.
    # Users are in a Parse.Relation, which requires a second query.
    netUsers = netRole.getUsers() 
    netQuery = netUsers.query().equalTo("objectId", req.user.id).first()

    profileQuery = (new Parse.Query "Profile").include("user").equalTo("objectId", req.object.get("profile").id).first()

    Parse.Promise.when(netQuery, profileQuery)
    .then( (netObj, profile) ->
      objsToSave = []
      user = profile.get "user"

      # Set ACL
      unless req.object.existed()

        # Let managers adjust the status
        # Note that we use a beforeSave to catch unauthorized status updates.

        # We won't set visible to the building until they accept.
        managerACL = new Parse.ACL
        managerACL.setRoleReadAccess netRole, true
        managerACL.setRoleWriteAccess netRole, true
        if user
          managerACL.setReadAccess user.id, true
          managerACL.setReadAccess user.id, true
        req.object.setACL managerACL

      # Check if the REQUEST user is in the role.
      if netObj

        # Upgrade the status
        if req.object.existed() and status and status is 'pending' and newStatus and newStatus is 'current'

          # Made it!
          # Add the user to the managerACL list
          if user
            # User must certainly exist at this point...
            user.set "network", network
            objsToSave.push user

            netRole.getUsers().add user
            objsToSave.push netRole

          # Set the manager as visible to other managers.
          managerACL = req.object.getACL()
          managerACL.setRoleReadAccess vstRole, true
          managerACL.setRoleWriteAccess vstRole, true
          req.object.setACL managerACL

          # Create activity
          # activity = new Parse.Object("Activity")
          # activityACL = new Parse.ACL
          # activityACL.setRoleReadAccess netRole, true if netRole

          # activity.set
          #   activity_type: "new_manager"
          #   public: false
          #   center: network.get "center"
          #   # manager: req.object
          #   network: network
          #   profile: profile
          #   ACL: activityACL
          # objsToSave.push activity

        else
          newStatus = 'invited'

          # Notify the user.
          title = network.get "title"
          notificationACL = new Parse.ACL
          notificationACL.setReadAccess user.id, true
          notificationACL.setReadAccess user.id, true
          notification = new Parse.Object("Notification").save
            name: "network_invitation"
            text: "You have been invited to join #{title}"
            channels: [ "profiles-#{profile.id}" ]
            channel: "profiles-#{profile.id}"
            forMgr: false
            withAction: true
            subject: network.get("profile")
            object: req.user.get("profile")
            network: network
            ACL: notificationACL
          objsToSave.push notification
        
        req.object.set "status", newStatus
            
      else

        # User is not a manager. User better be the person trying to join then.
        return res.error() unless req.object.get("profile").id is req.user.get("profile").id

        profileACL = profile.getACL()
        profileACL.setRoleReadAccess netRole, true
        profile.setACL profileACL
        objsToSave.push profile

        if req.object.existed() and status and status is 'invited' and newStatus and newStatus is 'current'

          # Add the user to the managerACL list
          if user
            user.set "network", network
            objsToSave.push user
            netRole.getUsers().add user
            objsToSave.push netRole

          # Set the manager as visible to other managers.
          managerACL = req.object.getACL()
          managerACL.setRoleReadAccess vstRole, true
          managerACL.setRoleWriteAccess vstRole, true
          req.object.setACL managerACL

          # Create activity
          # activity = new Parse.Object("Activity")
          # activityACL = new Parse.ACL
          # activityACL.setRoleReadAccess netRole, true

          # activity.set
          #   activity_type: "new_manager"
          #   public: false
          #   center: network.get "center"
          #   # manager: req.object
          #   network: network
          #   profile: profile
          #   ACL: activityACL
          # objsToSave.push activity

        else
          newStatus = 'pending'
          # Notify the network.
          notification = new Parse.Object("Notification")
          notificationACL = new Parse.ACL
          notificationACL.setRoleReadAccess netRole, true 
          notificationACL.setRoleWriteAccess netRole, true

          notification.set
            name: "manager_inquiry"
            text: "%NAME wants to join your network."
            channels: [ "networks-#{network.id}" ]
            channel: "networks-#{network.id}"
            forMgr: true
            withAction: true
            subject: profile
            object: network.get("profile")
            network: network
            ACL: notificationACL
          objsToSave.push notification
        
        req.object.set "status", newStatus

      Parse.Object.saveAll objsToSave, 
      success: -> res.success() # res.success network
      error: (error) -> res.error "bad_save"
    , -> res.error "bad_query"
    )
  error: -> res.error "bad_query"


# # Notification tasks
# Parse.Cloud.beforeSave "Notification", (req, res) ->

#   (new Parse.Query "Profile").equalTo('user', req.user).first()
#   .then (profile) ->
#     req.object.set "profile", profile
#     res.success()


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
    error: (error) -> req.object.save error: error.text
      
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
    profile = req.object.get("subject")
    name = if profile.get("first_name") then profile.get("first_name") 
    else if profile.get("name") then profile.get("name") 
    else if profile.get("last_name") then profile.get("last_name")
    else profile.get("email")
    if not name and profile.id
      new Parse.Query("Profile").get profile.id,
      success: (obj) ->
        name = if profile.get("first_name") then profile.get("first_name") 
        else if profile.get("name") then profile.get("name") 
        else if profile.get("last_name") then profile.get("last_name")
        else profile.get("email")
        text.replace("%NAME", name) 
        Parse.Push.send 
          channels: channels, data: alert: push_text
        , 
          # success: -> 
          error: (error) -> req.object.save error: JSON.stringify(error)
    else
      text.replace("%NAME", name) 
      Parse.Push.send 
        channels: channels, data: alert: push_text
      , 
        # success: -> 
        error: (error) -> req.object.save error: JSON.stringify(error)
  else 
    Parse.Push.send 
      channels: channels, data: alert: push_text
    , 
      # success: -> 
      error: (error) -> req.object.save error: JSON.stringify(error)

# # Search validation
# Parse.Cloud.beforeSave "Search", (req, res) ->
#   req.object.set 
#     user: req.user
#     ACL: new Parse.ACL() # Set to private
#   res.success()

# Post validation
Parse.Cloud.beforeSave "Activity", (req, res) ->

  return res.success() if req.object.existed()

  if req.object.get("accessToken") is "AZeRP2WAmbuyFY8tSWx8azlPEb"
    # We can use unset here.
    req.object.unset "accessToken"
    return res.success()

  # Set appropriate ACLs if this is a property post.
  if req.object.get "property"

    # Access the roles.
    Parse.Cloud.useMasterKey()

    # Query for the property
    (new Parse.Query "Property").include("role").include("mgrRole").include("network.role").get req.object.get("property").id,
    success: (property) ->
      propRole = property.get "role"
      mgrRole = property.get "mgrRole"
      network = property.get "network"

      # Create activityACL, unless we have one
      unless req.object.getACL()
        activityACL = new Parse.ACL
        activityACL.setReadAccess req.user.id, true
        activityACL.setWriteAccess req.user.id, true

        # Create activity
        if req.object.get "public"
          activityACL.setPublicReadAccess true 
        else 
          activityACL.setRoleReadAccess propRole, true if propRole
          activityACL.setRoleReadAccess mgrRole, true if mgrRole
          if network
            netRole = network.get "role"
            activityACL.setRoleReadAccess netRole, true if netRole

        req.object.setACL activityACL

      req.object.set
        property: property
        center: property.get "center"
        network: property.get "network"
        location: property.get "location"
        neighbourhood: property.get "neighbourhood"
        # Don't attach the profile by default.
        # profile: req.user.get "profile"
        # Why would we have this?
        # lease: req.user.get "lease" 
        # unit: req.user.get "unit"

      res.success()
    error: -> res.error "bad_query"

  else 
    req.object.set public: true
    unless req.object.getACL()
      activityACL = new Parse.ACL
      activityACL.setReadAccess req.user.id, true
      activityACL.setWriteAccess req.user.id, true
      activityACL.setPublicReadAccess true
      req.object.setACL activityACL

    # Make sure the profile is set if we don't have a property.
    req.object.set "subject", req.user.get("profile") unless req.object.get("subject")
    
    res.success()


Parse.Cloud.beforeSave "Comment", (req, res) ->
  return res.error "activity_missing" unless req.object.get("activity")

  return res.success() if req.object.existed()

  commentACL = new Parse.ACL
  commentACL.setPublicReadAccess true
  commentACL.setReadAccess req.user.id, true
  commentACL.setWriteAccess req.user.id, true

  req.object.setACL commentACL

  res.success()


Parse.Cloud.afterSave "Comment", (req) ->
  # Allow comments on every activity.
  Parse.Cloud.useMasterKey()
  query = new Parse.Query("Activity")
  query.get req.object.get("activity").include("profile").id,
  success: (obj) ->

    activityACL = new Parse.ACL
    activityACL.setPublicReadAccess true
    activityACL.setReadAccess req.user.id, true
    activityACL.setWriteAccess req.user.id, true

    notificationACL = new Parse.ACL
    notificationACL.setReadAccess obj.get("profile").get("user"), true
    notificationACL.setWriteAccess obj.get("profile").get("user"), true

    obj.increment "commentCount"

    activity = new Parse.Object("Activity")
    activity.set
      activity_type: "commented"
      title: "%NAME commented on #{model.get("name")}'s activity"
      public: true
      subject: req.user.get("profile")
      object: req.object.get("profile")
      ACL: activityACL

    # Notify the user if their activity has been liked
    if activity.get("commentCount") is 1 
      notification = new Parse.Object("Notification")
      notification.set
        text: "%NAME commented your activity."
        channels: [ "profiles-#{obj.get("profile").id}" ]
        channel: "profiles-#{obj.get("profile").id}"
        name: "commented"
        forMgr: false
        withAction: false
        # TODO: invitingProfile causes notification to not save.
        subject: req.user.get("profile")
        object: obj.get("profile")
        # email: req.object.get("profile").get("email")
        ACL: notificationACL
    
    Parse.Object.saveAll [obj, activity. notification]


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
