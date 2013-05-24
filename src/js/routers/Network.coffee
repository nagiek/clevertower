define [
  "jquery", 
  "backbone",
  "models/Network"
  "views/user/Menu"
  "views/network/Menu"
  "views/helper/Search"
], ($, Parse, Network, UserMenuView, NetworkMenuView, SearchView) ->

  class NetworkRouter extends Parse.Router
    routes:
      ""                                    : "index"
      "properties/new"                      : "propertiesNew"
      "properties/:id"                      : "propertiesShow"
      "properties/:id/*splat"               : "propertiesShow"
      "properties/:id/*splat"               : "propertiesShow"
      "network/*splat"                      : "networkManage"
      "users/:id"                           : "profileShow"
      "users/:id/*splat"                    : "profileShow"
      "account/:category"                   : "accountSettings"
      "*actions"                            : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      @userView = new UserMenuView().render()
      @networkView = new NetworkMenuView().render()
      new SearchView().render()
      
      Parse.Dispatcher.on "user:login", (user) =>
        Parse.User.current().setup().then =>
          @userView.render()
          @networkView.render()

          # Remove the Signup or Login callback
          Parse.history.off "route", @signupOrLogin
          
          # Go to the dashboard.
          Parse.history.navigate "/"
          @index()
      
      # Clean up after views
      Parse.history.on "route", (route) =>

        $('#search').val("").blur()
        @oldConstructor

        if @view 
          if @oldConstructor isnt @view.constructor
            @oldConstructor = @view.constructor
            @view.undelegateEvents()
            delete @view
        
      Parse.Dispatcher.on "network:set", => 
        # Remove the Access Denied callback
        Parse.history.off "route", @accessDenied
        
      Parse.Dispatcher.on "user:logout", (route) => 
        # Navigate after a second to the top level domain.
        domain = "#{location.protocol}//#{location.host.split(".").slice(1,3).join(".")}"
        setTimeout window.location.replace domain, 1000
      
      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).on "click", "a", (e) ->
        return if event.isDefaultPrevented
        # Get the anchor href
        href = $(this).attr("href")
        return if href is "#" or not href?
        # If this is a relative link on this domain.
        if href.substring(0,1) is '/' and href.substring(0,2) isnt '//'
          e.preventDefault()
          Parse.history.navigate href, true
          
      # If user is not a part of the network, return access denied.      
      if Parse.User.current()
        if Parse.User.current().get("network")
          role = Parse.User.current().get("network").get("role")
          role.getUsers().query().get Parse.User.current().id,
            success: (user) -> @accessDenied() unless user
        else
          Parse.history.on "route", @accessDenied
          @accessDenied()

      else
        Parse.history.on "route", @signupOrLogin
        @signupOrLogin()


    # Routes begin
    # --------------

    index: =>
      if Parse.User.current()
        @networkManage ""
      else
        @signupOrLogin()


    propertiesPublic: (id) =>
      require ["views/property/Public"], (PublicPropertyView) => 
        new Parse.Query("Property").get id,
          success: (model) => @view = new PublicPropertyView(model: model).render()
          error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL

    listingsPublic: (propertyId, id) =>
      require ["views/listing/Public"], (PublicListingView) => 
        new Parse.Query("Property").get propertyId,
          success: (property) => 
            new Parse.Query("Listing").get id,
              success: (model) => @view = new PublicListingView(property: property, model: model).render()
          error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL


    # Property
    # --------------

    propertiesNew: =>
      view = @view
      require ["views/network/Manage"], (NetworkView) => 
        if !view or view !instanceof NetworkView
          @view = new NetworkView(model: Parse.User.current().get("network"), path: "properties/new/wizard", params: {})
        else
          @view.changeSubView path: "properties/new/wizard", params: {}
    
    propertiesShow: (id, splat) =>
      view = @view
      require ["views/property/Show"], (PropertyView) =>
        vars = @deparamAction splat
        if !view or view !instanceof PropertyView
          $('#main').html '<div id="property"></div>'
          if model = Parse.User.current().get("network").properties.get id
            vars.model = model
            @view = new PropertyView(vars)
          else
            new Parse.Query("Property").get id,
            success: (model) =>
              # Network properties are being fetched. Might return before query finishes. 
              # Can't add to collection without introducing possibility of duplicate add.
              # @network.properties.add model
              model.collection = Parse.User.current().get("network").properties
              vars.model = model
              @view = new PropertyView(vars)
            error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL
        else
          view.changeSubView(vars.path, vars.params)

    # Network
    # --------------

    networkManage: (splat) =>
      view = @view
      require ["views/network/Manage"], (NetworkView) => 
        vars = @deparamAction splat
        if !view or view !instanceof NetworkView
          vars.model = Parse.User.current().get("network")
          @view = new NetworkView(vars)
        else
          view.changeSubView(vars.path, vars.params)


    # User
    # --------------
    
    profileShow : (id, splat) =>
      view = @view
      require ["models/Profile", "views/profile/Show"], (Profile, ShowProfileView) =>
        vars = @deparamAction splat
        if !view or view !instanceof ShowProfileView
          if Parse.User.current().profile and id is Parse.User.current().profile.id
            @view = new ShowProfileView path: vars.path, params: vars.params, model: Parse.User.current().profile, current: true
          else
            (new Parse.Query(Profile)).get id,
            success: (obj) => 
              @view = new ShowProfileView path: vars.path, params: vars.params, model: obj, current: false
        else
          view.changeSubView(vars.path, vars.params)

    accountSettings : (category) ->
      if category is 'edit'
        require ["views/profile/edit"], (UserSettingsView) =>
          @view = new UserSettingsView(model: Parse.User.current().profile, current: true).render()
      else
        require ["views/user/#{category}"], (UserSettingsView) =>
          @view = new UserSettingsView(model: Parse.User.current()).render()
  
  
  

    # Utilities
    # --------------
  
    deparamAction : (splat) ->
      ary = if splat then splat.split('?') else new Array('')
      combo = 
        path: ary[0]
        params: if ary[1] then @deparam ary[1] else {}
      
    
    deparam : (querystring) ->
      # remove any preceding url and split
      querystring = querystring.split('&')
      params = {}
      d = decodeURIComponent
      # march and parse
      for combo in querystring
        pair = combo.split('=')
        params[d(pair[0])] = d(pair[1])
      params
      
    accessDenied: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        Parse.history.navigate "/"
        
    signupOrLogin: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'warning'
          fade:     true
          heading:  i18nCommon.errors.not_logged_in