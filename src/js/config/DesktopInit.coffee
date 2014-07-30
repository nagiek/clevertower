# DesktopInit.js
# --------------
require.config
  
  # Sets the js folder as the base directory for all future relative paths
  baseUrl: "/js"
  
  # 3rd party script alias names (Easier to type "jquery" than "libs/jquery, etc")
  # probably a good idea to keep version numbers in the file names for updates checking
  paths:
    
    # Core Libraries
    # --------------
    jquery:                   "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min"     # "libs/jquery/jquery"
    jqueryui:                 "libs/jqueryui/jquery-ui-1.10.3.custom.min",                  # includes core, widget, slider, datepicker
    # underscore:               "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min"
    underscore:               "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min" # "libs/underscore/lodash"
    # backbone:                 "//www.parsecdn.com/js/parse-1.2.11"
    backbone:                 "libs/parse/parse-1.2.11"
                              
    # Async Libraries         
    # ---------------         
    # gmaps: (See below)      "//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"
    facebook:                 "//connect.facebook.net/en_US/all"
                              
    # jQuery Libraries        
    # ---------------
    jqueryuiwidget:           "libs/jqueryui/jquery.ui.widget.min",                         # 1.10.2
    jquerymobile:             "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min" # "libs/jquery/jquery.mobile.min"
    datepicker:               "libs/bootstrap/bootstrap-datepicker.min"
    # datepicker:               "libs/moment/moment-datepicker.min"
    # datepickermobile:         "libs/jqueryui/jquery.ui.datepicker.mobile.min"
    serializeObject:          "app/plugins/serialize_object"
    filePicker:               "app/plugins/file_picker"
    # toggler:                  "app/plugins/toggler"
    masonry:                  "libs/jquery/jquery.masonry"
    transit:                  "libs/jquery/jquery.transit"
    infinity:                 "libs/jquery/infinity"
    rangeSlider:              "libs/jquery/jquery.rangeSlider"
    slideshowify:             "libs/jquery/jquery.slideshowify"
    "jquery.fileupload-pr":   "app/plugins/jquery-fileupload-pr"  # Profile  (single)
    "jquery.fileupload-ui":   "app/plugins/jquery-fileupload-ui"  # UI       (multiple)
    "jquery.fileupload-fp":   "app/plugins/jquery-fileupload-fp"  # File Processing
    "jquery.fileupload":      "app/plugins/jquery-fileupload"
    "load-image":             "libs/plugins/load-image"            # "//blueimp.github.io/JavaScript-Load-Image/js/load-image.min"
    "canvas-to-blob":         "libs/plugins/canvas-to-blob"        # "//blueimp.github.io/JavaScript-Canvas-to-Blob/js/canvas-to-blob.min"      
                              
    # Underscore plugins      
    # ---------------
    "underscore.email":       "app/plugins/underscore-email"
    "underscore.inflection":  "app/plugins/underscore-inflection"
    "underscore.string":      "//cdnjs.cloudflare.com/ajax/libs/underscore.string/2.3.0/underscore.string.min"
                              
    # Plugins                 
    # ---------------
    typeahead:                "libs/typeahead.js/typeahead"
    pusher:                   "//d3dy5gmtp8yhk7.cloudfront.net/2.0/pusher.min"
    moment:                   "//cdnjs.cloudflare.com/ajax/libs/moment.js/2.0.0/moment.min"
    bootstrap:                "libs/bootstrap/bootstrap"    
    json2:                    "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2"                 # "libs/plugins/json2"

    # RequireJS Plugins       
    # -----------------       
    text:                     "libs/plugins/text"
    async:                    "libs/plugins/async"
    goog:                     "libs/plugins/goog"
    propertyParser:           "libs/plugins/propertyParser"
    i18n:                     "libs/plugins/i18n"
                              
    # Application Folders     
    # -------------------     
    collections:              "app/collections"
    models:                   "app/models"
    nls:                      "app/nls"
    plugins:                  "app/plugins"
    routers:                  "app/routers"
    templates:                "app/templates"
    views:                    "app/views"
      
  
  # Sets the configuration for your third party scripts that are not AMD compatible
  shim:
    bootstrap: ["jquery"]
    jqueryui: ["jquery"]
    jqueryuiwidget: ["jquery"]
    jquerymobile: ["jquery"]
    typeahead: ["jquery"]
    # infinity: ["jquery"]
    
    # datepickermobile: ["jquerymobile", "jqueryui"]
    backbone:
      deps: ["underscore", "jquery"]
      exports: "Parse"
    pusher:
      exports: "Pusher"
    underscore:
      exports: "_"


window.GCLIENT_ID = "318583282454-5r9n44vinmdfg9eakbbgnoa1iddk0f27.apps.googleusercontent.com"
window.GAPI_KEY   = "AIzaSyDX4LWzK2LTiw4EJFKlOHwBK3m7AmIdpgE"
window.APPID      = "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu"
window.JSKEY      = "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm"
window.RESTAPIKEY = "NZDSkpVLG9Gw6NiZOUBevvLt4qPGtpCsLvWh4ZDc"

  # config:
  #   i18n:
  #     locale: "fr-fr"
      # locale: localStorage.getItem("locale") || "fr-fr"


# Google JS API
define "gapi", ["async!//apis.google.com/js/client.js?onload="], ->

  # Note: following was added to async.plugin to accommodate client.js.
  # if (name.indexOf("onload=")>0) {name += id;}

  window.gapi.client.setApiKey window.GAPI_KEY
  # window.setTimeout ->
  #   scopes = """
  #   https://www.googleapis.com/auth/userinfo.profile
  #   https://www.googleapis.com/auth/userinfo.email
  #   https://www.googleapis.com/auth/contacts&
  #   """
  #   window.gapi.auth.authorize
  #     client_id: window.GCLIENT_ID
  #     scope: scopes
  #     immediate: true
  #   # , handleAuthResult
  # , 1

  window.gapi

# convert Google Maps into an AMD module
define "gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3.11&libraries=places&sensor=false&key=#{window.GAPI_KEY}"], ->
  # New look.
  google.maps.visualRefresh = true
  # return the gmaps namespace for brevity
  window.google.maps


# Alter the router depending on if we are on a subdomain or not, judging by the amount of "." chars.
# This will bug out on "www" subdomain.
# onNetwork = window.location.host.split(".").length > 2
# router = if onNetwork then "routers/Network" else "routers/Desktop"
require [
  "jquery"
  "underscore"
  "backbone"
  "facebook"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "models/Location"
  "models/Profile"
  "collections/LocationList"
  "collections/ListingFeaturedList"
  "collections/ActivityList"
  "collections/CommentList"
  "collections/NotificationList"
  "collections/ProfileList"
  "routers/Desktop",
  "underscore.string"
  "json2"
  "bootstrap"
  "serializeObject"
  "typeahead"
  "masonry"
  "transit"
], ($, _, Parse, FB, Property, Unit, Lease, Location, Profile, LocationList, FeaturedListingList, ActivityList, CommentList, NotificationList, ProfileList, AppRouter, _String) ->

  # Events
  # ---------

  # # Regular expression used to split event strings.
  eventSplitter = /\s+/

  # Implement fancy features of the Events API such as multiple event
  # names `"change blur"` and jQuery-style event maps `{change: action}`
  # in terms of the existing API.
  eventsApi = (obj, action, name, rest) ->
    return true  unless name
    
    # Handle event maps.
    if typeof name is "object"
      for key of name
        obj[action].apply obj, [key, name[key]].concat(rest)
      return false
    
    # Handle space separated event names.
    if eventSplitter.test(name)
      names = name.split(eventSplitter)
      i = 0
      l = names.length

      while i < l
        obj[action].apply obj, [names[i]].concat(rest)
        i++
      return false
    true


  # Add missing Parse Events
  Parse.Events.once = (name, callback, context) ->
    return this  if not eventsApi(this, "once", name, [callback, context]) or not callback
    self = this
    once = _.once(->
      self.off name, once
      callback.apply this, arguments
    )
    once._callback = callback
    @on name, once, context

  Parse.Object::once = Parse.Events.once
  Parse.View::once = Parse.Events.once
  Parse.Collection::once = Parse.Events.once

  # Add Listen functionality.

  # Inversion-of-control versions of `on` and `once`. Tell *this* object to
  # listen to an event in another object ... keeping track of what it's
  # listening to.
  listenMethods =
    listenTo: "on"
    listenToOnce: "once"
  listenEvents = {}

  _.each listenMethods, (implementation, method) ->
    listenEvents[method] = (obj, name, callback) ->
      listeners = @_listeners or (@_listeners = {})
      id = obj._listenerId or (obj._listenerId = _.uniqueId("l"))
      listeners[id] = obj
      callback = @  if typeof name is "object"
      obj[implementation] name, callback, @
      @

  listenEvents.stopListening = (obj, name, callback) ->
    listeners = @_listeners
    return @  unless listeners
    deleteListener = not name and not callback
    callback = @  if typeof name is "object"
    (listeners = {})[obj._listenerId] = obj  if obj
    for id of listeners
      listeners[id].off name, callback, @
      delete @_listeners[id]  if deleteListener
    @

  _.extend Parse.Router.prototype, listenEvents
  _.extend Parse.View.prototype, listenEvents
  _.extend Parse.Object.prototype, listenEvents

  # View
  # -------

  # Remove this view by taking the element out of the DOM, and removing any
  # applicable Backbone.Events listeners.
  Parse.View::remove = ->
    @$el.remove()
    @stopListening()
    @

  # Collection
  # -------

  # Default options for `Collection#set`.
  setOptions =
    add: true
    remove: true
    merge: true

  addOptions =
    add: true
    remove: false

  # Add missing countBy method.
  Parse.Collection::countBy = -> _.countBy.apply _, [this.models].concat(_.toArray(arguments))

  Parse.Collection::add = (models, options) ->
    @set models, _.extend(
      merge: false
    , options, addOptions)
  
  # Update a collection by `set`-ing a new list of models, adding new ones,
  # removing models that are no longer present, and merging models that
  # already exist in the collection, as necessary. Similar to **Model#set**,
  # the core operation for updating the data contained by the collection.
  Parse.Collection::set = (models, options) ->
    options = _.defaults({}, options, setOptions)
    models = @parse(models, options)  if options.parse
    singular = not _.isArray(models)
    models = (if singular then ((if models then [models] else [])) else _.clone(models))
    i = undefined
    l = undefined
    id = undefined
    model = undefined
    attrs = undefined
    existing = undefined
    sort = undefined
    at = options.at
    targetModel = @model
    sortable = @comparator and (not (at?)) and options.sort isnt false
    sortAttr = (if _.isString(@comparator) then @comparator else null)
    toAdd = []
    toRemove = []
    modelMap = {}
    add = options.add
    merge = options.merge
    remove = options.remove
    order = (if not sortable and add and remove then [] else false)
    
    # Turn bare objects into model references, and prevent invalid models
    # from being added.
    i = 0
    l = models.length

    while i < l
      attrs = models[i]
      if attrs instanceof Parse.Object
        id = model = attrs
      else
        id = attrs[targetModel::idAttribute]
      
      # If a duplicate is found, prevent it from being added and
      # optionally merge it into the existing model.
      if existing = @get(id)
        modelMap[existing.cid] = true  if remove
        if merge
          attrs = (if attrs is model then model.attributes else attrs)
          attrs = existing.parse(attrs, options)  if options.parse
          existing.set attrs, options
          sort = true  if sortable and not sort and existing.hasChanged(sortAttr)
        models[i] = existing
      
      # If this is a new, valid model, push it to the `toAdd` list.
      else if add
        model = models[i] = @_prepareModel(attrs, options)
        continue  unless model
        toAdd.push model
        
        # Listen to added models' events, and index models for lookup by
        # `id` and by `cid`.
        model.on "all", @_onModelEvent, this
        @_byId[model.cid] = model
        @_byId[model.id] = model  if model.id?
      order.push existing or model  if order
      i++
    
    # Remove nonexistent models if appropriate.
    if remove
      i = 0
      l = @length

      while i < l
        toRemove.push model  unless modelMap[(model = @models[i]).cid]
        ++i
      @remove toRemove, options  if toRemove.length
    
    # See if sorting is needed, update `length` and splice in new models.
    if toAdd.length or (order and order.length)
      sort = true  if sortable
      @length += toAdd.length
      if at?
        i = 0
        l = toAdd.length

        while i < l
          @models.splice at + i, 0, toAdd[i]
          i++
      else
        @models.length = 0  if order
        orderedModels = order or toAdd
        i = 0
        l = orderedModels.length

        while i < l
          @models.push orderedModels[i]
          i++
    
    # Silently sort the collection if appropriate.
    @sort silent: true  if sort
    
    # Unless silenced, it's time to fire all appropriate add/sort events.
    unless options.silent
      i = 0
      l = toAdd.length

      while i < l
        (model = toAdd[i]).trigger "add", model, this, options
        i++
      @trigger "sort", this, options  if sort or (order and order.length)
    
    # Return the added (or merged) model (or models).
    (if singular then models[0] else models)

  # App
  # ---------

  Parse.initialize window.APPID, window.JSKEY

  Parse.App = {}

  Parse.App.featuredListings = new FeaturedListingList 
  Parse.App.activity = new ActivityList [], {}
  Parse.App.comments = new CommentList [], {}

  Parse.App.fbPerms = "email, publish_actions, user_location, user_about_me, user_birthday, user_website" #, publish_stream, read_stream"

  # Hard coded.
  # Do not overwrite: these have objectIds which you will have to lookup...
  locationAttributes =
    [
      objectId: "WqL44FLrni"
      googleName: "Montreal--QC--Canada"
      isCity: true
      center: new Parse.GeoPoint(45.5,-73.566667)
    ,
      objectId: "mzHk9SyFCh"
      googleName: "Le-Plateau-Mont-Royal--Montreal--QC--Canada"
      isCity: false
      center: new Parse.GeoPoint(45.521646, -73.57545)
    ,
      objectId: "peW8RrUqxj"
      googleName: "Toronto--ON--Canada" 
      isCity: true
      center: new Parse.GeoPoint(43.6537228,-79.373571)
    ,
      objectId: "7Huyd0XF8M"
      googleName: "The-Beaches--Toronto--ON--Canada" 
      isCity: false
      center: new Parse.GeoPoint(43.667266,-79.297128)
    ]
  profileAttributes =
    [
      objectId: "dGlN9B9eOs"
      fbID: 102184499823699
      name: "Montreal"
      bio: 'Originally called Ville-Marie, or "City of Mary", it is named after Mount Royal, the triple-peaked hill located in the heart of the city.'
      image_thumb: "/img/city/Montreal--QC--Canada.jpg"
      image_profile: "/img/city/Montreal--QC--Canada.jpg"
      image_full: "/img/city/Montreal--QC--Canada.jpg"
    ,
      objectId: "d0lLcU5FJL"
      fbID: 106014166105010
      name: "The Plateau-Mont-Royal"
      bio: 'The Plateau-Mont-Royal is the most densely populated borough in Canada, with 101,054 people living in an 8.1 square kilometre area.'
      image_thumb: "/img/city/Montreal--QC--Canada.jpg"
      image_profile: "/img/city/Montreal--QC--Canada.jpg"
      image_full: "/img/city/Montreal--QC--Canada.jpg"
    ,
      objectId: "QZcUnUwJOE"
      fbID: 110941395597405
      name: "Toronto" 
      bio: 'Canada’s most cosmopolitan city is situated on beautiful Lake Ontario, and is the cultural heart of south central Ontario and of English-speaking Canada.'
      image_thumb: "/img/city/Toronto--ON--Canada.jpg"
      image_profile: "/img/city/Toronto--ON--Canada.jpg"
      image_full: "/img/city/Toronto--ON--Canada.jpg"
    ,
      objectId: "ZN3GHkpw7j"
      fbID: 111084918946366
      name: "The Beaches"
      bio: 'The Beaches (also known as "The Beach") is a neighbourhood and popular tourist destination. It is located on the east side of the "Old" City of Toronto.'
      image_thumb: "/img/city/Toronto--ON--Canada.jpg"
      image_profile: "/img/city/Toronto--ON--Canada.jpg"
      image_full: "/img/city/Toronto--ON--Canada.jpg"
    ]
  locations = []

  for attrs, i in locationAttributes
    attrs.profile = new Profile(profileAttributes[i])
    locations.push new Location(attrs)

  Parse.App.locations = new LocationList locations, {}


  # Bootstrap
  # ---------

  # When we click a button in a dropdown, keep dropdown alive.
  # $(document).on 'click.dropdown.data-api', '.dropdown form button', (e) -> e.stopPropagation()


  # Underscore
  # ---------

  # Import Underscore.string to separate object, because there are conflict functions (include, reverse, contains)
  _.str = _String
  
  # Always include these headers, unless otherwise noted.
  if window isnt undefined and window.$ then
    $.ajaxSetup beforeSend: (jqXHR, settings) ->
      jqXHR.setRequestHeader "X-Parse-Application-Id", window.APPID
      jqXHR.setRequestHeader "X-Parse-REST-API-Key", window.RESTAPIKEY

  # init the FB JS SDK
  Parse.FacebookUtils.init
    appId      : '387187337995318'                        # Facebook App ID
    channelUrl : "//#{window.location.host}/fb-channel"   # Channel File (must be absolute path)
    cookie     : true                                     # enable cookies to allow Parse to access the session
    xfbml      : false                                    # parse XFBML
    # status     : true                                     # check login status


  # Bring Parse Collection up to speed with Backbone methods.
  Parse.Collection::where = (attrs, first) ->
    if _.isEmpty(attrs) 
      return if first then undefined else [];
    @[if first then 'find' else 'filter'] (model) ->
      for key in attrs
        if (attrs[key] isnt model.get(key)) then return false
      true

  Parse.Collection::findWhere = (attrs) -> @where attrs, true

  # Extend Parse User
  Parse.User::defaults = 
    privacy_visible:  false
    privacy_unit:     false
    type:             "tenant"
  
  Parse.User::validate = (attrs, options) ->

    # Original function
    if _.has(attrs, "ACL") and !(attrs.ACL instanceof Parse.ACL)
      return new Parse.Error Parse.Error.OTHER_CAUSE, "ACL must be a Parse.ACL."

    # Our new validations
    if attrs.email and attrs.email isnt ""
      return {message: "invalid_email"} unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test attrs.email
    false  

  # Load all the stuff
  Parse.User::setup = ->

    new Parse.Query("_User")
    .include('lease')
    .include('unit')
    .include('profile')
    .include('property.profile')
    .include('property.role')
    .include('property.mgrRole')
    .include('network.role')
    .equalTo("objectId", @id)
    .first().then (user) => 

      return unless user

      # Profile.
      profile = user.get "profile"
      
      profile.likes = new ActivityList [], subject: profile
      profile.likes.query = profile.relation("likes").query().include("subject")

      profile.following = new ProfileList [], {}
      profile.following.query = profile.relation("following").query().include("property")

      profile.followers = new ProfileList [], {}
      profile.followers.query = profile.relation("followers").query().include("property")

      profile.followingActivity = new ActivityList [], {}
      profile.followingActivity.query = Parse.Query.or(
        # These two queries do not play nicely together...
        new Parse.Query("Activity").matchesQuery("subject", profile.relation("following").query())
        ,
        new Parse.Query("Activity").matchesKeyInQuery("location", "location", profile.relation("following").query())
      # Include activity.subject and object, as we may have "likes" and "follow" activity.
      ).include("property.profile").include("subject").include("location.profile").include("activity.subject").include("object")


      profile.followingComments = new CommentList [], {}
      profile.followingComments.query.matchesQuery "profile", profile.relation("following").query()

      @set "profile", profile

      @activity = new ActivityList [], {} unless @activity
      @comments = new CommentList [], {} unless @comments

      # Living.
      @set "lease", user.get "lease"
      # Need to get the Unit functions when managing our lease.
      @set "unit", user.get "unit"
      # if user.get("unit") then @set "unit", new Unit(user.get("unit").attributes)

      # Need Property methods for posting
      property = user.get "property"
      if property
        @set "property", property
        @propertySetup()
      # if user.get("property") then @set "property", new Property(user.get("property").attributes)

      # Load the network regardless if we are on a subdomain or not, as we need the link.
      # Should query for network when loading user... this is weird.
      # Set network on current user from loaded user.
      network = user.get "network"
      if network
        @set "network", network
        @networkSetup()

      # Notifications.
      # Set up after we have set the property and network.
      @notifications = new NotificationList
      @notifications.query.find(success: (notifs) => @notifications.add notifs)

  Parse.User::propertySetup = ->

    property = @get "property"
    
    property.prep("units").fetch()
    property.prep("activity") # .fetch()
    property.prep("comments") # .fetch()
    property.prep("managers") # .fetch()
    property.prep("tenants") # .fetch()
    property.prep("listings") # .fetch()
    property.prep("applicants") # .fetch()
    property.prep("inquiries") # .fetch()

  Parse.User::networkSetup = ->

    network = @get "network"

    # Create & fill our collections
    # Can't use a Promise here, as fetch does not return a promise.
    network.prep("properties").fetch()
    network.prep("activity") # .fetch()
    network.prep("comments") # .fetch()
    network.prep("units") # .fetch()
    network.prep("managers") # .fetch()
    network.prep("tenants") # .fetch()
    network.prep("listings") # .fetch()
    network.prep("applicants") # .fetch()
    network.prep("inquiries") # .fetch()

    # Set the network and the role on the user.
    role = network.get("role")
    role.getUsers().query().equalTo("objectId", Parse.User.current().id).first()
    .then (user) => network.mgr = true; @set "network", network
      , => network.mgr = false; @set "network", network

  # Set up Dispatcher for global events
  Parse.Dispatcher = {}
  _.extend(Parse.Dispatcher, Parse.Events)

  # Load the user's profile before loading the app.
  # @see LoggedOutView::login
  if Parse.User.current()
    Parse.User.current().setup().then -> new AppRouter()
  else
    new AppRouter()
