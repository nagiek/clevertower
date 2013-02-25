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
    bootstrap:              "libs/bootstrap/bootstrap"
    text:                   "libs/plugins/text"
    i18n:                   "libs/plugins/i18n"
    
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
    
  config:
    i18n:
      locale: localStorage.getItem('locale') || 'en-en'


# Includes Desktop Specific JavaScript files here (or inside of your Desktop router)
require ["jquery", "backbone", "routers/App", "json2", "jqueryui", "bootstrap"], ($, Parse, AppRouter) ->
  
  Parse.initialize "6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO", "Jf4WgWUgu7R39oy5AZotay42dEDY5neMEoJddKEY" # JS Key
  
  # Instantiates a new Desktop Router instance
  new AppRouter()
  
  # # Only need this for pushState enabled browsers
  # if Parse.history and Parse.history._hasPushState
  # 
  #   # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
  #   $(document).delegate "a", "click", (e) ->
  #   
  #     # Get the anchor href and protcol
  #     href = $(this).attr("href")
  #     protocol = @protocol + "//"
  #   
  #     # Ensure the protocol is not part of URL, meaning its relative.
  #     # Stop the event bubbling to ensure the link will not cause a page refresh.
  #     if href.slice(protocol.length) isnt protocol
  #       e.preventDefault()
  #   
  #       # Note by using Backbone.history.navigate, router events will not be
  #       # triggered.  If this is a problem, change this to navigate on your
  #       # router.
  #       Parse.history.navigate href, true

