# Mobile/Desktop Detection script
((ua, w, d, undefined_) ->
  
  # App Environment
  # ---------------
  #  Tip: Set to true to turn on "production" mode
  production = false
  
  # Configuration object that will contain the correct prod/dev CSS and JavaScript files to load
  config = {}
  
  # Listen to the DOMContentLoaded Event (Supported in IE9+, Chrome Firefox, Safari)
  w.addEventListener "DOMContentLoaded", (->
    # Loaded when in production mode
    loadCSS = (urls, callback) ->
      x = undefined
      link = undefined
      x = 0
      while x <= urls.length - 1
        link = d.createElement("link")
        link.type = "text/css"
        link.rel = "stylesheet"
        link.href = urls[x]
        d.querySelector("head").appendChild link
        x += 1
      callback()  if callback
    loadJS = (files, callback) ->
      x = undefined
      script = undefined
      file = undefined
      x = 0
      while x <= files.length - 1
        file = files[x]
        script = d.createElement("script")
        if ((typeof file).toLowerCase()) is "object" and file["data-main"] isnt `undefined`
          script.setAttribute "data-main", file["data-main"]
          script.src = file.src
        else
          script.src = file
        d.body.appendChild script
        x += 1
      callback()  if callback
    loadFiles = (obj, callback) ->
      if production
        
        # Loads the production CSS file(s)
        loadCSS obj["prod-css"], ->
          
          # If there are production JavaScript files to load
          
          # Loads the correct initialization file (which includes Almond.js)
          loadJS obj["prod-js"], callback  if obj["prod-js"]

      
      # Else if your app is in development mode
      else
        
        # Loads the development CSS file(s)
        loadCSS obj["dev-css"], ->
          
          # If there are development Javascript files to load
          
          # Loads Require.js and tells Require.js to find the correct intialization file
          loadJS obj["dev-js"], callback  if obj["dev-js"]

    if (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/).test(ua)
      config =
        "dev-css": ["/css/libs/jquery.mobile.css"]
        "prod-css": ["/css/libs/jquery.mobile.min.css"]
        "dev-js": [
          "data-main": "/js/app/config/MobileInit.js"
          src: "/js/libs/require/require.js"
        ]
        "prod-js": ["/js/app/config/MobileInit.min.js"]
    else
      config =
        "dev-css": []
        "prod-css": []
        "dev-js": [
          "data-main": "/js/app/config/DesktopInit.js"
          src: "/js/libs/require/require.js"
        ]
        "prod-js": ["/js/app/config/DesktopInit.min.js"]
    loadFiles config, ->
      loadFiles
        "dev-css": ["/css/cali.css"]
        "prod-css": ["/css/cali.min.css"]


  ), false
) navigator.userAgent or navigator.vendor or window.opera, window, window.document