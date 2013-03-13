# MobileInit.js
# -------------
require.config
  
  # Sets the js folder as the base directory for all future relative paths
  baseUrl: "/js"
  
  # 3rd party script alias names (Easier to type "jquery" than "libs/jquery, etc")
  # probably a good idea to keep version numbers in the file names for updates checking
  paths:
    
    # Core Libraries
    # --------------
    jquery:       '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min'     # "libs/jquery"
    jqueryui:     'libs/jqueryui/jquery-ui-1.10.1.custom.min',                  # includes core, widget, slider, datepicker
    underscore:   "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min" # "libs/lodash"
    parse:        "//www.parsecdn.com/js/parse-1.1.15.min"                      # "libs/parse"
    
    # Bonus Libraries
    # ---------------
    # gmaps:            "//maps.googleapis.com/maps/api/js?sensor=false" # &key=my_api_key
    json2:            "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2",
    jquerymobile:     '//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min'
    datepickermobile: 'libs/jqueryui/jquery.ui.datepicker.mobile.min',
    
    # Plugins
    # -------
    serializeObject:        "app/plugins/serialize_object"
    filePicker:             "app/plugins/file_picker"
    bootstrap:              "libs/bootstrap/bootstrap.min"
    text:                   "libs/plugins/text"
    async:                  "libs/plugins/async"
    propertyParser:         "libs/plugins/propertyParser"
    i18n:                   "libs/plugins/i18n"
    
    # Application Folders
    # -------------------
    collections:  "app/collections"
    models:       "app/models"
    nls:          "app/nls"
    routers:      "app/routers"
    templates:    "app/templates"
    views:        "app/views"

  
  # Sets the dependency and shim configurations
  # - Helpful for including non-AMD compatible scripts and managing dependencies
  shim:
    
    # Twitter Bootstrap jQuery plugins
    bootstrap: ["jquery"]
    
    # jQueryUI
    jqueryui: ["jquery"]
    
    # jQueryMobile
    jquerymobile: ["jquery"]

    # jQueryUI Datepicker Mobile
    datepickermobile: ["jquerymobile", "jqueryui"]
    
    # Backbone
    backbone:
      
      # Depends on underscore/lodash and jQuery
      deps: ["underscore", "jquery"]
      
      # Exports the global window.Backbone object
      exports: "Backbone"
    
  config:
    i18n:
      locale: localStorage.getItem('locale') || 'en-en'


# Include Desktop Specific JavaScript files here (or inside of your Desktop router)
require ["jquery", "backbone", "routers/Mobile", "json2", "jqueryui", "jquerymobile", "datepickermobile", "serializeObject"], ($, Backbone, AppRouter) ->
  
  # Prevents all anchor click handling
  $.mobile.linkBindingEnabled = false
  
  # Disabling this will prevent jQuery Mobile from handling hash changes
  $.mobile.hashListeningEnabled = false
  
  # Instantiates a new Mobile Router instance
  new AppRouter()
