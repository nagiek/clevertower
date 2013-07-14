define [
  "jquery", 
  "backbone",
  "views/user/UserMenu"
  "views/user/NavMenu"
  "views/helper/Search"
], ($, Parse, UserMenuView, NavMenuView, SearchView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                            : "index"
      "properties/new"              : "propertiesNew"
      "places/:country/:region/:city/:id/:slug" : "propertiesPublic"
      "outside/*splat"               : "search"
      "outside"                      : "search"
      # "inside"                      : "propertiesManage"
      # "inside/*splat"               : "propertiesManage"
      "network/new"                 : "networkNew"
      # Network
      "listings/new"                : "listingsNew"
      "leases/new"                  : "leasesNew"
      "tenants/new"                 : "tenantsNew"
      "properties/new"              : "propertiesNew"
      "properties/:id"              : "propertiesManage"
      "properties/:id/*splat"       : "propertiesManage"
      "properties/:id/*splat"       : "propertiesManage"
      "inside/*splat"               : "insideManage"
      "inside"                      : "insideManage"
      # User
      "users/:id"                   : "profileShow"
      "users/:id/*splat"            : "profileShow"
      "notifications"               : "notifications"
      "account/setup"               : "accountSetup"
      "account/signup"              : "signup"
      "account/reset_password"      : "resetPassword"
      "account/login"               : "login"
      "account/logout"              : "logout"
      # "account/history/:category"   : "accountHistory"
      "account/*splat"              : "accountSettings"
      "oauth2callback"              : "oauth2callback"
      # "*actions"                    : "fourOhFour" # 404

    initialize: (options) ->
      Parse.history.start pushState: true
      
      new UserMenuView().render()
      new NavMenuView().render()
      Parse.App.search = new SearchView().render()
            
      @listenTo Parse.Dispatcher, "user:login", (user) =>      
        unless Parse.User.current().get("network") or Parse.User.current().get("property")
          # require ["views/helper/Alert", 'i18n!nls/property'], (Alert, i18nProperty) =>
          #   new Alert
          #     event:    'no_network'
          #     type:     'warning'
          #     fade:     true
          #     heading:  i18nProperty.errors.network_not_set
          Parse.history.navigate "account/setup"
          @accountSetup()
        else
          # Reload the current path. Don't use navigate, as it will fail.
          # The route functions themselves are responsible for altering content.
          Parse.history.loadUrl location.pathname
          
      @listenTo Parse.Dispatcher, "user:logout", =>
        # Reload the current path. Don't use navigate, as it will fail.
        # The route functions themselves are responsible for altering content.
        Parse.history.loadUrl location.pathname
      
      
      # Clean up after views
      @listenTo Parse.history, "route", (route) =>

        $('#search-menu input.search').val("").blur()

        if @view
          if @oldCID and @oldCID isnt @view.cid
            @oldCID = @view.cid
            @view.trigger "view:change"
            # @view.undelegateEvents()
            # @view.stopListening()
            # delete @view
  
      
      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).on "click", "a", (e) ->
        return if e.isDefaultPrevented()
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
      view = @view
      if Parse.User.current()
        require ["views/activity/index"], (ActivityIndexView) =>
          if !view or view !instanceof ActivityIndexView
            @view = new ActivityIndexView(params: {}).render()  
      else 
        require ["views/home/anon"], (AnonHomeView) =>
          if !view or view !instanceof AnonHomeView
            @view = new AnonHomeView(params: {}).render()

    search: (splat) ->
      view = @view
      require ["views/activity/index"], (ActivityIndexView) =>
        if !view or view !instanceof ActivityIndexView
          vars = @deparamAction splat
          @view = new ActivityIndexView(location: vars.path, params: vars.params).render()

    # Network
    # --------------
    networkNew: =>
      view = @view
      require ["views/network/New"], (NewNetworkView) => 
        @view = new NewNetworkView()
        @view.setElement "#main"
        @view.render()

    insideManage: (splat) =>
      view = @view
      if Parse.User.current()
        if Parse.User.current().get("network")
          require ["views/network/Manage"], (NetworkView) => 
            vars = @deparamAction splat
            if !view or view !instanceof NetworkView
              vars.model = Parse.User.current().get("network")
              @view = new NetworkView(vars)
            else
              view.changeSubView(vars.path, vars.params)
        else if Parse.User.current().get("property")
          # If we can see the mgrRole, we must be part of it.
          # Yes, this looks strange, but it works.
          # 
          # TODO: Or does it? Can't see propRole either. Check "AddTenants" function.
          if Parse.User.current().get("property").get("mgrRole")
            # Parse.User.current().get("property").get("mgrRole").getUsers().query().get Parse.User.current().id,
            # success: =>
            @propertiesManage Parse.User.current().get("property").id, splat
          else
          # error: =>
            require ["views/lease/Manage"], (LeaseView) => 
              if !view or view !instanceof LeaseView
                vars.model = Parse.User.current().get("lease")
                @view = new LeaseView(vars)
              else
                view.changeSubView(vars.path, vars.params)
        else 
          Parse.history.navigate "/account/setup"
          @accountSetup()
      else
        @signupOrLogin()


    # Property
    # --------------

    # DIFFERENT FROM NETWORK
    # FOR USER
    propertiesNew: =>
      view = @view
      require ["views/property/new/Wizard"], (PropertyWizard) =>
        if !view or view !instanceof PropertyWizard
          @view = new PropertyWizard forNetwork: false
          @view.setElement "#main"
          @view.render()

    # DIFFERENT FROM NETWORK
    # FOR USER
    propertiesManage: (id, splat) =>

      view = @view
      vars = @deparamAction splat
      # Check if we are managing the property or the lease.
      if Parse.User.current().get("network") or Parse.User.current().get("property")
        require ["views/property/Manage"], (PropertyView) => 
          if !view or view !instanceof PropertyView

            if Parse.User.current().get("network")
              model = Parse.User.current().get("network").properties.get id
            else if Parse.User.current().get("property")
              model = Parse.User.current().get("property")

            if model
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
        
      else
        Parse.history.navigate "account/setup"
        @accountSetup()

    propertiesPublic: (country, region, city, id, slug) =>
      place = "#{city}--#{region}--#{country}"
      require ["models/Property", "views/property/Public"], (Property, PublicPropertyView) => 
        new Parse.Query(Property).get id,
          success: (model) =>
            @view = new PublicPropertyView(model: model, place: place).render()
          error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL


    # User
    # --------------

    profileShow : (id, splat) =>
      view = @view
      require ["models/Profile", "views/profile/Show"], (Profile, ShowProfileView) =>
        vars = @deparamAction splat
        if !view or view !instanceof ShowProfileView
          # Default id is current user
          if not id and Parse.User.current() then id = Parse.User.current().get("profile").id

          if Parse.User.current() and Parse.User.current().get("profile") and id is Parse.User.current().get("profile").id
            @view = new ShowProfileView path: vars.path, params: vars.params, model: Parse.User.current().get("profile"), current: true
          else
            (new Parse.Query(Profile)).get id,
            success: (obj) => 
              @view = new ShowProfileView path: vars.path, params: vars.params, model: obj, current: false
        else
          view.changeSubView vars.path, vars.params

    accountSetup : ->
      if Parse.User.current()
        require ["views/user/Setup"], (NewNetworkView) =>              
          @view = new NewNetworkView(model: Parse.User.current().get("network")) # if !@view or @view !instanceof NewNetworkView
          @view.render()
      else
        @signupOrLogin()

    accountSettings : (splat) ->
      view = @view
      if splat is 'edit'
        require ["views/profile/edit"], (EditProfileView) =>
          @view = new EditProfileView(model: Parse.User.current().get("profile"), current: true).render()
      else
        require ["views/user/Account"], (UserAccountView) =>
          vars = @deparamAction splat

          if !view or view !instanceof UserAccountView
            @view = new UserAccountView vars
          else
            view.changeSubView vars.path, vars.params
  
    notifications : ->
      if Parse.User.current()
        require ["views/notification/All"], (AllNotificationsView) =>
          @view = new AllNotificationsView().render()
      else
        @signupOrLogin()


    # Auth
    # --------------

    signup : ->
      unless Parse.User.current()
        require ["views/user/Signup"], (SignupView) =>
          @view = new SignupView().render()
      else
        Parse.history.navigate "users/#{Parse.User.current().get("profile").id}"
        @profileShow()

    login : ->
      unless Parse.User.current()
        require ["views/user/Login"], (LoginView) =>
          @view = new LoginView().render()
      else
        Parse.history.navigate "users/#{Parse.User.current().get("profile").id}"
        @profileShow()

    resetPassword : ->
      require ["views/user/Reset"], (ResetView) =>
        @view = new ResetView().render()

    logout : ->
      if Parse.User.current()
        Parse.User.logOut()
        Parse.Dispatcher.trigger "user:change"
        Parse.Dispatcher.trigger "user:logout"
        Parse.history.navigate ""
        @index()
      else 
        Parse.history.navigate "/account/login"
        @login()


    # OAuth
    # --------------

    oauth2callback : ->
      if Parse.User.current()
        # Variables will be placed in a hash querystring.
        vars = @deparam window.location.hash.substring(1)
        unless vars.error
          # We shold verify, but we won't be accepted on localhost
          $.ajax "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=#{vars.access_token}",
          # Include a blank beforeSend to override the default headers.
          beforeSend: (jqXHR, settings) ->
          success: (res) -> 
            if res.audience and res.audience is window.GCLIENT_ID
              res.access_token = vars.access_token
              res.expires_in += new Date().getTime() / 1000
              Parse.User.current().save(googleAuthData: res).then ->
                Parse.history.navigate vars.state, true
            else
              require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
                new Alert
                  event:    'access-denied'
                  type:     'error'
                  fade:     true
                  heading:  i18nCommon.oauth.error
                  message:  i18nCommon.oauth.unverified_token
              Parse.history.navigate vars.state, true
        else
          require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
            new Alert
              event:    'access-denied'
              type:     'error'
              fade:     true
              heading:  i18nCommon.oauth.error
              message:  i18nCommon.oauth[vars.error]
          Parse.history.navigate vars.state, true
      else
        @signupOrLogin()  


    # Utilities
    # --------------
  
    fourOhFour : ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'access-denied'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.fourOhFour
          message:  i18nCommon.errors.not_found
        Parse.history.navigate "/", true

    deparamAction : (splat) ->
      unless splat then return path: "", params: {}
      
      indexOfHash = splat.indexOf("#")
      if indexOfHash >= 0 then splat = splat.substr(0, indexOfHash)
      ary = if splat.indexOf("?") >= 0 then splat.split('?') else new Array(splat)
      combo = 
        path: String ary[0]
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
        # Parse.history.navigate "/", true
        
    signupOrLogin: ->
      # require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
      #   new Alert
      #     event:    'routing-canceled'
      #     type:     'warning'
      #     fade:     true
      #     heading:  i18nCommon.errors.not_logged_in
      #   Parse.history.navigate "/", true
      $("#login-modal").modal()