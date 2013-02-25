# DesktopInit.js
# --------------
require.config
  
  # Sets the js folder as the base directory for all future relative paths
  baseUrl: "./js"
  
  # 3rd party script alias names (Easier to type "jquery" than "libs/jquery, etc")
  # probably a good idea to keep version numbers in the file names for updates checking
  paths:
    
    # Core Libraries
    # --------------
    jquery:       '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min' # "libs/jquery"
    jqueryui:     'libs/jqueryui/jquery-ui-1.10.1.custom.min', # includes core, slider, datepicker
    underscore:   "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min" # "libs/lodash"
    backbone:     "//www.parsecdn.com/js/parse-1.1.15.min" # "libs/parse"
    
    # Bonus Libraries
    # ---------------
    json2:            "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2",
    jquerymobile:     '//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min'
    datepickermobile: 'libs/jqueryui/jquery.ui.datepicker.mobile.min',
    
    # Plugins
    # -------
    "backbone.validateAll": "libs/plugins/Backbone.validateAll"
    bootstrap:              "libs/bootstrap/bootstrap"
    text:                   "libs/plugins/text"
    
    # Application Folders
    # -------------------
    collections:  "app/collections"
    models:       "app/models"
    routers:      "app/routers"
    templates:    "app/templates"
    views:        "app/views"

  
  # Sets the configuration for your third party scripts that are not AMD compatible
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
      exports: "Parse"
    
    # Backbone.validateAll plugin that depends on Backbone
    "backbone.validateAll": ["backbone"]
    
  config:
    i18n:
      locale: localStorage.getItem('locale') || 'en-en'


# Includes Desktop Specific JavaScript files here (or inside of your Desktop router)
require ["jquery", "backbone", "routers/DesktopRouter", "json2", "jqueryui", "bootstrap", "backbone.validateAll"], ($, Backbone, DesktopRouter) ->
  
  # Instantiates a new Desktop Router instance
  new DesktopRouter()
