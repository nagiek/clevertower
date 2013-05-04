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
    # jqueryui:                 "libs/jqueryui/jquery-ui-1.10.1.custom.min",                  # includes core, widget, slider, datepicker
    # underscore:               "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min"
    underscore:               "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min" # "libs/underscore/lodash"
    backbone:                 "//www.parsecdn.com/js/parse-1.2.7"                       # "libs/backbone/parse"
                              
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
    toggler:                  "app/plugins/toggler"
    masonry:                  "libs/jquery/jquery.masonry"
    "jquery.fileupload-pr":   "app/plugins/jquery-fileupload-pr" # Profile  (single)
    "jquery.fileupload-ui":   "app/plugins/jquery-fileupload-ui" # UI       (multiple)
    "jquery.fileupload-fp":   "app/plugins/jquery-fileupload-fp" # File Processing
    "jquery.fileupload":      "app/plugins/jquery-fileupload"
    "load-image":             "//blueimp.github.com/JavaScript-Load-Image/load-image.min"             # "libs/jquery/load-image.min"
    "canvas-to-blob":         "//blueimp.github.com/JavaScript-Canvas-to-Blob/canvas-to-blob.min"     # "libs/jquery/canvas-to-blob.min"
                              
    # Underscore plugins      
    # ---------------
    "underscore.email":       "app/plugins/underscore-email"
    "underscore.inflection":  "app/plugins/underscore-inflection"
    "underscore.string":      "//cdnjs.cloudflare.com/ajax/libs/underscore.string/2.3.0/underscore.string.min"
                              
    # Plugins                 
    # ---------------
    typeahead:                "libs/typeahead.js/typeahead-computed"
    pusher:                   "//d3dy5gmtp8yhk7.cloudfront.net/2.0/pusher.min"
    moment:                   "//cdnjs.cloudflare.com/ajax/libs/moment.js/2.0.0/moment.min"
    bootstrap:                "libs/bootstrap/bootstrap"    
    json2:                    "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2"                 # "libs/plugins/json2"

    # RequireJS Plugins       
    # -----------------       
    text:                     "libs/plugins/text"
    async:                    "libs/plugins/async"
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
    
    # datepickermobile: ["jquerymobile", "jqueryui"]
    backbone:
      deps: ["underscore", "jquery"]
      exports: "Parse"
    pusher:
      exports: "Pusher"
    underscore:
      exports: "_"

window.GMAPS_KEY  = "AIzaSyDX4LWzK2LTiw4EJFKlOHwBK3m7AmIdpgE"
window.APPID      = "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu"
window.JSKEY      = "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm"
window.RESTAPIKEY = "NZDSkpVLG9Gw6NiZOUBevvLt4qPGtpCsLvWh4ZDc"

  # config:
  #   i18n:
  #     locale: "fr-fr"
      # locale: localStorage.getItem("locale") || "fr-fr"

# convert Google Maps into an AMD module
define "gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3.11&libraries=places&sensor=false&key=#{window.GMAPS_KEY}"], ->

  # return the gmaps namespace for brevity
  window.google.maps


# Alter the router depending on if we are on a subdomain or not, judging by the amount of "." chars.
# This will bug out on "www" subdomain.
onNetwork = window.location.host.split(".").length > 2
router = if onNetwork then "routers/Network" else "routers/Desktop"
require ["jquery", "underscore", "backbone", "facebook", "models/Profile", router, "underscore.string", "json2", "bootstrap", "serializeObject", "typeahead", "masonry"], ($, _, Parse, FB, Profile, AppRouter, _String) ->

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

  _.extend Parse.View.prototype, listenEvents
  _.extend Parse.Object.prototype, listenEvents

  # Remove this view by taking the element out of the DOM, and removing any
  # applicable Backbone.Events listeners.
  Parse.View::remove = ->
    @$el.remove()
    @stopListening()
    @





  Parse.initialize window.APPID, window.JSKEY
  Parse.App = {}

  # Import Underscore.string to separate object, because there are conflict functions (include, reverse, contains)
  _.str = _String
  
  # Always include these headers, unless otherwise noted.
  $.ajaxSetup beforeSend: (jqXhr, settings) ->
    jqXhr.setRequestHeader "X-Parse-Application-Id", window.APPID
    jqXhr.setRequestHeader "X-Parse-REST-API-Key", window.RESTAPIKEY

  Parse.onNetwork = onNetwork

  # init the FB JS SDK
  Parse.FacebookUtils.init
    appId      : '387187337995318'                        # Facebook App ID
    channelUrl : '//clevertower.dev:3000/fb-channel'      # Channel File (must be absolute path)
    cookie     : true                                     # enable cookies to allow Parse to access the session
    xfbml      : true                                     # parse XFBML
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
    profilePromise = (new Parse.Query(Profile)).equalTo("user", @).first()
    networkPromise = (new Parse.Query("_User")).include('network.role').equalTo("objectId", @id).first()
    Parse.Promise.when(profilePromise, networkPromise).then (profile, user) => 

      profile.prep("applicants").fetch()
      @profile = profile

      # Load the network regardless if we are on a subdomain or not, as we need the link.
      # Should query for network when loading user... this is weird.
      # Set network on current user from loaded user.
      network = user.get "network" if user

      if user and network
        # Create & fill our collections
        # Can't use a Promise here, as fetch does not return a promise.
        network.prep("properties").fetch()
        network.prep("managers").fetch()
        network.prep("tenants").fetch()
        network.prep("listings").fetch()
        network.prep("applicants").fetch()
        network.prep("inquiries").fetch()
        
        # Set the network and the role on the user.
        @set "network", network


  # Set up Dispatcher for global events
  Parse.Dispatcher = {}
  _.extend(Parse.Dispatcher, Parse.Events)

  # Load the user's profile before loading the app.
  # @see LoggedOutView::login
  if Parse.User.current()
    Parse.User.current().setup().then -> new AppRouter()
  else
    new AppRouter()
