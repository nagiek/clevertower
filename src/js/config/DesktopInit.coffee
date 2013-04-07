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
    backbone:                 "//www.parsecdn.com/js/parse-1.2.2"                       # "libs/backbone/parse"
                              
    # Async Libraries         
    # ---------------         
    # See below               
    # gmaps:                    "//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"
                              
    # jQuery Libraries        
    # ---------------
    jqueryuiwidget:           "libs/jqueryui/jquery.ui.widget.min",                         # 1.10.2
    jquerymobile:             "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min" # "libs/jquery/jquery.mobile.min"
    datepicker:               "libs/bootstrap/bootstrap-datepicker.min"
    # datepicker:               "libs/moment/moment-datepicker.min"
    # datepickermobile:         "libs/jqueryui/jquery.ui.datepicker.mobile.min"
    serializeObject:          "app/plugins/serialize_object"
    filePicker:               "app/plugins/file_picker"
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
                              
    # Plugins                 
    # ---------------
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
    routers:                  "app/routers"
    templates:                "app/templates"
    views:                    "app/views"
      
  
  # Sets the configuration for your third party scripts that are not AMD compatible
  shim:
    bootstrap: ["jquery"]
    jqueryui: ["jquery"]
    jqueryuiwidget: ["jquery"]
    jquerymobile: ["jquery"]

    # datepickermobile: ["jquerymobile", "jqueryui"]
    backbone:
      deps: ["underscore", "jquery"]
      exports: "Parse"
    pusher:
      exports: "Pusher"
    underscore:
      exports: "_"
    
  # config:
  #   i18n:
  #     locale: "fr-fr"
      # locale: localStorage.getItem("locale") || "fr-fr"

# convert Google Maps into an AMD module
define "gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"], ->

  # return the gmaps namespace for brevity
  window.google.maps



# Includes Desktop Specific JavaScript files here (or inside of your Desktop router)
require ["jquery", "backbone", "collections/property/PropertyList", "models/Profile", "routers/Desktop", "json2", "bootstrap", "serializeObject"], ($, Parse, PropertyList, Profile, AppRouter) ->
  
  Parse.initialize "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu", "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm" # JS Key  

  # Setup
  # Extend Parse User
  Parse.User::defaults = 
    privacy_visible:  false
    privacy_unit:     false
  
  # Setup
  # Extend Parse User
  Parse.User::validate = (attrs, options) ->

    # Original function
    if _.has(attrs, "ACL") and !(attrs.ACL instanceof Parse.ACL)
      return new Parse.Error Parse.Error.OTHER_CAUSE, "ACL must be a Parse.ACL."

    # Our new validations
    if attrs.email and attrs.email isnt ""
      return {message: "invalid_email"} unless /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test attrs.email
    false  

  # Load the user's profile before loading the app.
  # @see LoggedOutView::login
  if Parse.User.current()
    
    # Create our collection of Properties
    Parse.User.current().properties = new PropertyList
    
    (new Parse.Query(Profile)).equalTo("user", Parse.User.current()).first()
    .then (profile) => 
      Parse.User.current().profile = profile
      new AppRouter()
  else
    new AppRouter()
