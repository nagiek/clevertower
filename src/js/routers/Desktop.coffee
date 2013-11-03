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
      "places/:country/:region/:city/:id/:slug" : "propertiesPublic"
      "posts/:id"                   : "activityShow"
      "outside/*splat"              : "outside"
      "outside*splat"               : "outside"
      # "inside"                      : "propertiesManage"
      # "inside/*splat"               : "propertiesManage"
      "network/new"                 : "networkNew"
      # Network
      "listings/new"                : "listingsNew"
      "leases/new"                  : "leasesNew"
      "tenants/new"                 : "tenantsNew"
      "movein"                      : "movein"
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
      # "account/confirm"             : "accountConfirm"
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

      $("#sidebar-toggle").click -> $("body").toggleClass("active")
          
      @listenTo Parse.Dispatcher, "user:login", =>
        if Parse.User.current().get("network") or Parse.User.current().get("property")
          # Reload the current path. 
          # Don't use navigate, as it will fail.
          # The route functions themselves are responsible for altering content.
          Parse.history.loadUrl location.pathname
        else
          # require ["views/helper/Alert", 'i18n!nls/property'], (Alert, i18nProperty) =>
          #   new Alert
          #     event:    'no_network'
          #     type:     'warning'
          #     fade:     true
          #     heading:  i18nProperty.errors.network_not_set
          Parse.history.navigate "account/setup", true

      @listenTo Parse.Dispatcher, "user:logout", =>
        # Reload the current path. Don't use navigate, as it will fail.
        # The route functions themselves are responsible for altering content.
        Parse.history.loadUrl location.pathname
      

      # Reset global view state.
      @listenTo Parse.history, "route", (router, route, params) => Parse.App.search.$('input').val("").blur() 
      
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
            view.clear() if view
      else 
        require ["views/home/anon"], (AnonHomeView) =>
          if !view or view !instanceof AnonHomeView
            @view = new AnonHomeView(params: {}).render()
            view.clear() if view

    outside: (splat) ->
      view = @view
      require ["views/activity/index"], (ActivityIndexView) =>
        if !view or view !instanceof ActivityIndexView
          vars = @deparamAction splat
          @view = new ActivityIndexView(location: vars.path, params: vars.params).render()
          view.clear() if view

    # 
    # 

    activityShow: (id) =>
      view = @view
      require ["collections/ActivityList", "views/activity/Show"], (ActivityList, ShowActivityView) =>
        if !view or view !instanceof ShowActivityView or id isnt view.model.id
          Parse.App.activity = Parse.App.activity || new ActivityList [], {}
          model = Parse.App.activity.get id
          if model 
            @view = new ShowActivityView(model: model).render()
            view.clear() if view
          else
            new Parse.Query("Activity").get id,
              success: (model) =>
                Parse.App.activity.add model
                @view = new ShowActivityView(model: model).render()
                view.clear() if view
              error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL

    # Network
    # --------------
    networkNew: =>
      view = @view
      require ["views/network/New"], (NewNetworkView) => 
        @view = new NewNetworkView()
        @view.setElement "#main"
        @view.render()
        view.clear() if view

    insideManage: (splat) =>
      view = @view
      if Parse.User.current()
        if Parse.User.current().get("network")
          require ["views/network/Manage"], (NetworkView) => 
            vars = @deparamAction splat
            if !view or view !instanceof NetworkView
              vars.model = Parse.User.current().get("network")
              @view = new NetworkView(vars)
              view.clear() if view
            else
              view.changeSubView(vars.path, vars.params)
        else if Parse.User.current().get("property")

          # If we are here for the first time, check whether or not the user is the manager.
          if Parse.User.current().get("property").mgr is undefined
            if Parse.User.current().get("property").get("mgrRole")
              Parse.User.current().get("property").get("mgrRole").getUsers().query().get Parse.User.current().id,
                success: (user) =>
                  if user
                    Parse.User.current().get("property").mgr = true
                    @propertiesManage Parse.User.current().get("property").id, splat
                  else
                    Parse.User.current().get("property").mgr = false
                    require ["views/lease/Manage"], (LeaseView) => 
                      vars = @deparamAction splat
                      if !view or view !instanceof LeaseView
                        vars.model = Parse.User.current().get("lease")
                        @view = new LeaseView(vars)
                        view.clear() if view
                      else
                        view.changeSubView(vars.path, vars.params)
                error: (error) =>
                  console.log error
                  Parse.User.current().get("property").mgr = false
                  @insideManage(splat)
            else
              Parse.User.current().get("property").mgr = false
              @insideManage(splat)
          else 
            # Cached answer
            if Parse.User.current().get("property").mgr
              # Parse.User.current().get("property").get("mgrRole").getUsers().query().get Parse.User.current().id,
              # success: =>
              @propertiesManage Parse.User.current().get("property").id, splat
            else
            # error: =>
              require ["views/lease/Manage"], (LeaseView) => 
                vars = @deparamAction splat
                if !view or view !instanceof LeaseView
                  vars.model = Parse.User.current().get("lease")
                  @view = new LeaseView(vars)
                  view.clear() if view
                else
                  view.changeSubView(vars.path, vars.params)
        else 
          Parse.history.navigate "account/setup", true
          # @accountSetup()
      # Handling this in the NavMenu view. This URL is exposed, and
      # should not be followed through, which is why it shouldn't be
      # handled by @signupOrLogin
      else
        Parse.history.navigate "account/login", true


    # Property
    # --------------

    # DIFFERENT FROM NETWORK
    # FOR USER
    movein: =>
      view = @view
      require ["views/property/new/Wizard"], (PropertyWizard) =>
        if !view or view !instanceof PropertyWizard
          @view = new PropertyWizard forNetwork: false
          @view.setElement "#main"
          @view.render()
          view.clear() if view

    propertiesNew: =>
      view = @view
      require ["views/property/new/Wizard"], (PropertyWizard) =>
        if !view or view !instanceof PropertyWizard
          @view = new PropertyWizard forNetwork: true
          @view.setElement "#main"
          @view.render()
          view.clear() if view

    # DIFFERENT FROM NETWORK
    # FOR USER
    propertiesManage: (id, splat) =>

      if Parse.User.current()
        view = @view
        vars = @deparamAction splat
        # Check if we are managing the property or the lease.
        if Parse.User.current().get("network") or Parse.User.current().get("property")
          require ["views/property/Manage"], (ManagePropertyView) => 
            if !view or view !instanceof ManagePropertyView or id isnt view.model.id

              model = if Parse.User.current().get("network")
                Parse.User.current().get("network").properties.get id
              else Parse.User.current().get("property")

              if model
                vars.model = model
                @view = new ManagePropertyView(vars)
                view.clear() if view
              else
                new Parse.Query("Property").get id,
                success: (model) =>
                  Parse.User.current().get("network").properties.add model
                  vars.model = model
                  @view = new ManagePropertyView(vars)
                  view.clear() if view
                error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL
            else
              view.changeSubView(vars.path, vars.params)
          
        else
          Parse.history.navigate "account/setup", true
          # @accountSetup()
      else
        @signupOrLogin()

    propertiesPublic: (country, region, city, id, slug) =>
      view = @view
      place = "#{city}--#{region}--#{country}"
      require ["models/Property", "views/property/Public"], (Property, PublicPropertyView) => 
        if Parse.User.current()
          if Parse.User.current().get("property") and id is Parse.User.current().get("property").id 
            @view = new PublicPropertyView(params: {}, model: Parse.User.current().get("property"), place: place).render()
            view.clear() if view
          else if Parse.User.current().get("network") and Parse.User.current().get("network").properties.find((p) -> p.id is id)
            model = Parse.User.current().get("network").properties.find((p) -> p.id is id)
            @view = new PublicPropertyView(params: {}, model: model, place: place).render()
            view.clear() if view
          else
            new Parse.Query(Property).get id,
              success: (model) =>
                @view = new PublicPropertyView(params: {}, model: model, place: place).render()
                view.clear() if view
              error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL
        else
          new Parse.Query(Property).get id,
            success: (model) =>
              @view = new PublicPropertyView(params: {}, model: model, place: place).render()
              view.clear() if view
            error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL


    # New
    # --------------
    
    listingsNew: =>
      view = @view
      require ["views/listing/new"], (NewListingView) =>
        if !view or view !instanceof NewListingView
          @view = new NewListingView(forNetwork: true, baseUrl: "/inside/listings")
          @view.setElement "#main"
          @view.render()
          view.clear() if view

    leasesNew: =>
      view = @view
      require ["views/lease/new"], (NewLeaseView) =>
        if !view or view !instanceof NewLeaseView
          @view = new NewLeaseView(forNetwork: true, baseUrl: "/inside/tenants")
          @view.setElement "#main"
          @view.render()
          view.clear() if view

    tenantsNew: =>
      view = @view
      require ["views/tenant/new"], (NewTenantView) =>
        if !view or view !instanceof NewTenantView
          @view = new NewTenantView(forNetwork: true, baseUrl: "/inside/tenants")
          @view.setElement "#main"
          @view.render()
          view.clear() if view


    # User
    # --------------

    profileShow : (id, splat) =>
      view = @view
      require ["models/Profile", "views/profile/Show"], (Profile, ShowProfileView) =>
        vars = @deparamAction splat
        if !view or view !instanceof ShowProfileView or id isnt view.model.id
          # Default id is current user
          if not id and Parse.User.current() then id = Parse.User.current().get("profile").id

          if Parse.User.current() and Parse.User.current().get("profile") and id is Parse.User.current().get("profile").id
            @view = new ShowProfileView path: vars.path, params: vars.params, model: Parse.User.current().get("profile"), current: true
            view.clear() if view
          else
            (new Parse.Query(Profile)).get id,
            success: (obj) => 
              @view = new ShowProfileView path: vars.path, params: vars.params, model: obj, current: false
              view.clear() if view
        else
          view.changeSubView vars.path, vars.params

    accountSetup : ->
      view = @view
      if Parse.User.current()
        require ["views/user/Setup"], (UserSetupView) =>              
          @view = new UserSetupView().render()
          view.clear() if view
      else
        @signupOrLogin()

    # accountConfirm : ->
    #   if Parse.User.current()
    #     require ["views/user/Confirm"], (UserConfirmView) =>              
    #       @view = new UserConfirmView().render()
    #   else
    #     @signupOrLogin()

    accountSettings : (splat) ->
      view = @view
      if splat is 'edit'
        require ["views/profile/edit"], (EditProfileView) =>
          @view = new EditProfileView(model: Parse.User.current().get("profile"), current: true).render()
          view.clear() if view
      else
        require ["views/user/Account"], (UserAccountView) =>
          vars = @deparamAction splat

          if !view or view !instanceof UserAccountView
            @view = new UserAccountView vars
            view.clear() if view
          else
            view.changeSubView vars.path, vars.params
  
    notifications : ->
      view = @view
      if Parse.User.current()
        require ["views/notification/All"], (AllNotificationsView) =>
          @view = new AllNotificationsView().render()
          view.clear() if view
      else
        @signupOrLogin()


    # Auth
    # --------------

    signup : ->
      view = @view
      unless Parse.User.current()
        require ["views/user/Signup"], (SignupView) =>
          @view = new SignupView().render()
          view.clear() if view
      else
        Parse.history.navigate "users/#{Parse.User.current().get("profile").id}"
        @profileShow()

    login : ->
      view = @view
      unless Parse.User.current()
        require ["views/user/Login"], (LoginView) =>
          @view = new LoginView().render()
          view.clear() if view
      else
        Parse.history.navigate "users/#{Parse.User.current().get("profile").id}"
        @profileShow()

    resetPassword : ->
      view = @view
      require ["views/user/Reset"], (ResetView) =>
        @view = new ResetView().render()
        view.clear() if view

    logout : ->
      view = @view
      if Parse.User.current()
        Parse.User.logOut()
        Parse.Dispatcher.trigger "user:change"
        Parse.Dispatcher.trigger "user:logout"
        Parse.history.navigate "", true
        # @index()
      else 
        Parse.history.navigate "account/login", true
        # @login()


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
                  type:     'danger'
                  fade:     true
                  heading:  i18nCommon.oauth.error
                  message:  i18nCommon.oauth.unverified_token
              Parse.history.navigate vars.state, true
        else
          require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
            new Alert
              event:    'access-denied'
              type:     'danger'
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
          type:     'danger'
          fade:     true
          heading:  i18nCommon.errors.fourOhFour
          message:  i18nCommon.errors.not_found
        Parse.history.navigate "", true

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
          type:     'danger'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        # Parse.history.navigate "", true
        
    signupOrLogin: ->
      # require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
      #   new Alert
      #     event:    'routing-canceled'
      #     type:     'warning'
      #     fade:     true
      #     heading:  i18nCommon.errors.not_logged_in
      #   Parse.history.navigate "", true
      $("#login-modal").modal()