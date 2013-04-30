define [
  "jquery", 
  "backbone",
  "views/user/Menu"
  "views/network/Menu"
  "views/helper/Search"
], ($, Parse, UserMenuView, NetworkMenuView, SearchView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                            : "index"
      "public/:id"                          : "propertiesPublic"
      "public/:propertyId/listings/:id"     : "listingsPublic"
      "network/set"                 : "networkSet"
      "network/:name"               : "networkShow"
      "users/:id"                   : "profileShow"
      "users/:id/*splat"            : "profileShow"
      "account/:category"           : "accountSettings"
      "*actions"                    : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      @userView = new UserMenuView().render()
      @networkView = new NetworkMenuView().render()
      new SearchView().render()
            
      Parse.Dispatcher.on "user:login", (user) =>
        Parse.User.current().setup().then =>
          @userView.render()
          @networkView.render()
          if Parse.User.current().get("type") is "manager" and !Parse.User.current().get("network")
            require ["views/helper/Alert", 'i18n!nls/property', "views/network/New"], (Alert, i18nProperty, NewNetworkView) =>
              new Alert
                event:    'no_network'
                type:     'warning'
                fade:     true
                heading:  i18nProperty.errors.network_not_set
              Parse.history.navigate "/network/set"
              @view = new NewNetworkView(model: Parse.User.current().get("network")) if !@view or @view !instanceof NetworkFormView
              @view.render()
          else
            # Reload the current path. Don't use navigate, as it will fail.
            # The route functions themselves are responsible for altering content.
            Parse.history.loadUrl location.pathname
          
      Parse.Dispatcher.on "user:logout", =>
        @userView.render()
        @networkView.render()
        # Reload the current path. Don't use navigate, as it will fail.
        # The route functions themselves are responsible for altering content.
        Parse.history.loadUrl location.pathname
      
      
      # Clean up after views
      Parse.history.on "route", (route) =>

        $('#search').val("").blur()
        @oldConstructor

        if @view 
          if @oldConstructor isnt @view.constructor
            @oldConstructor = @view.constructor
            @view.undelegateEvents()
            delete @view
  
      
      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).on "click", "a", (e) ->
        # Get the anchor href
        href = $(this).attr("href")
        return if href is "#" or not href?        
        # If this is a relative link on this domain.
        if href.substring(0,1) is '/' and href.substring(0,2) isnt '//'
          e.preventDefault()
          Parse.history.navigate href, true
          
          
    # Routes
    # --------------
          
    index: ->
      if Parse.User.current()
        $('#main').html """
                        <h1>News Feed</h1>
                        <div class="row">
                          <div class="span8">

                          </div>
                          <div class="span4">
                            <!-- if user.get('type') is 'manager' then  -->
                            <ul class="nav nav-list well"><li><a href="/network/set">Set up network</a></li></ul>
                          </div>
                        </div>
                        """
      else
        $('#main').html '<h1>Splash page</h1>'


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

    # User
    # --------------
    
    networkSet : ->
      if Parse.User.current()
        require ["views/network/New"], (NewNetworkView) =>              
          @view = new NewNetworkView(model: Parse.User.current().get("network")) # if !@view or @view !instanceof NewNetworkView
          @view.render()
      else
        @signupOrLogin()
    

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
      if Parse.User.current()
        if category is 'edit'
          require ["views/profile/edit"], (UserSettingsView) =>
            @view = new UserSettingsView(model: Parse.User.current().profile, current: true).render()
        else
          require ["views/user/#{category}"], (UserSettingsView) =>
            @view = new UserSettingsView(model: Parse.User.current()).render()
      else
        @signupOrLogin()
  
  
  

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
          event:    'access-denied'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        Parse.history.navigate "/", true
        
    signupOrLogin: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'warning'
          fade:     true
          heading:  i18nCommon.errors.not_logged_in
        Parse.history.navigate "/", true