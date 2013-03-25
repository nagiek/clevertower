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
    jquery:                   '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min'     # "libs/jquery/jquery"
    jqueryuiwidget:           'libs/jqueryui/jquery.ui.widget.min',                         # 1.10.2
    # jqueryui:                 'libs/jqueryui/jquery-ui-1.10.1.custom.min',                  # includes core, widget, slider, datepicker
    underscore:               '//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min' # "libs/underscore/lodash"
    backbone:                 "//www.parsecdn.com/js/parse-1.2.2.min"                       # "libs/backbone/parse"
                              
    # Async Libraries         
    # ---------------         
    # See below               
    # gmaps:                    "//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"
                              
    # jQuery Libraries        
    # ---------------
    jquerymobile:             '//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min' # "libs/jquery/jquery.mobile.min"
    datepicker:               'libs/bootstrap/bootstrap-datepicker.min'
    # datepicker:               'libs/moment/moment-datepicker.min'
    # datepickermobile:         'libs/jqueryui/jquery.ui.datepicker.mobile.min'
    serializeObject:          "app/plugins/serialize_object"
    filePicker:               "app/plugins/file_picker"
    "jquery.fileupload-pr":   'app/plugins/jquery-fileupload-pr' # Profile  (single)
    "jquery.fileupload-ui":   'app/plugins/jquery-fileupload-ui' # UI       (multiple)
    "jquery.fileupload-fp":   'app/plugins/jquery-fileupload-fp' # File Processing
    "jquery.fileupload":      "app/plugins/jquery-fileupload"
    'load-image':             '//blueimp.github.com/JavaScript-Load-Image/load-image.min'             # "libs/jquery/load-image.min"
    'canvas-to-blob':         '//blueimp.github.com/JavaScript-Canvas-to-Blob/canvas-to-blob.min'     # "libs/jquery/canvas-to-blob.min"
                              
    # Underscore plugins      
    # ---------------
    "underscore.email":       "app/plugins/underscore-email"
    "underscore.inflection":  "app/plugins/underscore-inflection"
                              
                              
    # Plugins                 
    # ---------------
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
    
    # Twitter Bootstrap jQuery plugins
    bootstrap: ["jquery"]
    
    # jQueryUI
    jqueryui: ["jquery"]
    
    # jQueryUI
    jqueryuiwidget: ["jquery"]
    
    # jQueryMobile
    jquerymobile: ["jquery"]

    # jQueryUI Datepicker Mobile
    # datepickermobile: ["jquerymobile", "jqueryui"]
    
    # Backbone
    backbone:
      
      # Depends on underscore/lodash and jQuery
      deps: ["underscore", "jquery"]
      
      # Exports the global window.Backbone object
      exports: "Parse"
      
    # Underscore
    underscore:
      deps: ['underscore.email', 'underscore.inflection'],
      exports: '_',
      init: (UnderscoreString) ->
        _.mixin(UnderscoreEmail)
        _.mixin(UnderscoreInflection)
    
  # config:
  #   i18n:
  #     locale: 'fr-fr'
      # locale: localStorage.getItem('locale') || 'fr-fr'

# convert Google Maps into an AMD module
define "gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"], ->

  # return the gmaps namespace for brevity
  window.google.maps



# Includes Desktop Specific JavaScript files here (or inside of your Desktop router)
require ["jquery", "backbone", "routers/Desktop", "json2", "bootstrap", "serializeObject"], ($, Parse, AppRouter) ->
  
  Parse.initialize "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu", "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm" # JS Key
  
  # Instantiates a new Desktop Router instance
  new AppRouter()
  