define [
  "jquery", 
  "backbone",
  "models/Network"
  "views/user/UserMenu"
  "views/user/NavMenu"
  "views/helper/Search"
], ($, Parse, Network, UserMenuView, NavMenuView, SearchView) ->

  class NetworkRouter extends Parse.Router
    routes:
      ""                            : "index"
      "properties/new"              : "propertiesNew"
      "properties/:id"              : "propertiesManage"
      "properties/:id/*splat"       : "propertiesManage"
      "properties/:id/*splat"       : "propertiesManage"
      "network/*splat"              : "networkManage"
      "users/:id"                   : "profileShow"
      "users/:id/*splat"            : "profileShow"
      # "inquiries"                   : "inquiries"
      # "building"                    : "building"
      "account/*splat"              : "accountSettings"
      "notifications"               : "notifications"
      "oauth2callback"              : "oauth2callback"
      "*actions"                    : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      new UserMenuView().render()
      new NavMenuView().render()
      Parse.App.search = new SearchView().render()
      
      @listenTo Parse.Dispatcher, "user:login", (user) =>
        @handleUserPriviledges()
        
        # Go to the dashboard.
        Parse.history.navigate "/"
        @index()

      @listenTo Parse.Dispatcher, "user:logout", => 
        # Navigate after a second to the top level domain.
        domain = "#{location.protocol}//#{location.host.split(".").slice(1,3).join(".")}"
        setTimeout window.location.replace domain, 1000
        @listenTo Parse.history, "route", @signupOrLogin        
        Parse.history.navigate "/"
        @index()

      # Clean up after views
      @listenTo Parse.history, "route", (route) =>

        $('#search').val("").blur()
        @oldConstructor

        if @view 
          if @oldConstructor isnt @view.constructor
            @oldConstructor = @view.constructor
            @view.undelegateEvents()
            delete @view
        
      if Parse.User.current()
        @handleUserPriviledges()
      else
        @listenTo Parse.history, "route", @signupOrLogin

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

    # DIFFERENT FROM DESKTOP
    # FOR NETWORK
    propertiesNew: =>
      view = @view
      require ["views/property/new/Wizard"], (PropertyWizard) =>
        if !view or view !instanceof PropertyWizard
          @view = new PropertyWizard forNetwork: true
          @view.setElement "#main"
          @view.render()


      # require ["views/network/Manage"], (NetworkView) => 
      #   if !view or view !instanceof NetworkView
      #     @view = new NetworkView(model: Parse.User.current().get("network"), path: "properties/new/wizard", params: {})
      #   else
      #     @view.changeSubView path: "properties/new/wizard", params: {}
    
    propertiesManage: (id, splat) =>
      view = @view
      require ["views/property/Manage"], (PropertyView) =>
        vars = @deparamAction splat
        if !view or view !instanceof PropertyView
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
          if Parse.User.current() and Parse.User.current().get("profile") and id is Parse.User.current().get("profile").id
            @view = new ShowProfileView path: vars.path, params: vars.params, model: Parse.User.current().get("profile"), current: true
          else
            (new Parse.Query(Profile)).get id,
            success: (obj) => 
              @view = new ShowProfileView path: vars.path, params: vars.params, model: obj, current: false
        else
          view.changeSubView(vars.path, vars.params)

    # accountHistory : (category) ->
    #   view = @view
    #   require ["views/user/Account", "views/user/sub/History"], (UserAccountView, UserHistoryView) =>
    #     vars = @deparamAction "history/#{category}"
    #     if !view or view !instanceof UserHistoryView
    #       # We have to load the UserAccountView first.
    #       @view = new UserAccountView path: vars.path, params: vars.params
    #     else
    #       view.changeSubView(vars.path, vars.params)

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
  
    # building : ->
    #   if Parse.User.current()
    #     require ["views/user/Building"], (UserBuildingView) =>
    #         @view = new UserBuildingView().render()
    #   else
    #     @signupOrLogin()
  
    # inquiries : ->
    #   if Parse.User.current()
    #     require ["views/inquiries/Index"], (InquiriesIndexView) =>
    #         @view = new InquiriesIndexView().render()
    #   else
    #     @signupOrLogin()

    # OAuth
    # --------------

    oauth2callback : ->
      if Parse.User.current()
        # Variables will be placed in a hash querystring.
        vars = @deparam window.location.hash.substring(1)
        console.log window.location.hash
        console.log vars
        console.log Parse.Cloud
        unless vars.error
          # We shold verify, but we won't be accepted on localhost
          # $.get "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=#{vars.accessToken}", null, (verify) -> 
          #   if verify.audience is window.GCLIENT_ID
          Parse.User.current().save(accessToken: vars.accessToken).then ->
            Parse.history.navigate vars.state, true
            # else
            #   require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
            #     new Alert
            #       event:    'access-denied'
            #       type:     'error'
            #       fade:     true
            #       heading:  i18nCommon.oauth.error
            #       message:  i18nCommon.oauth.unverified_token
            #   Parse.history.navigate vars.state, true
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

    pendingApproval: ->
      Parse.history.navigate "/"
      # @index()
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.pending_approval
          message:  i18nCommon.errors.not_yet_accepted
      
    accessDenied: ->
      Parse.history.navigate "/"
      # @index()
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        
    signupOrLogin: ->      
      # @index()
      $("#login-modal").modal()
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'routing-canceled'
          type:     'warning'
          fade:     true
          heading:  i18nCommon.errors.not_logged_in
        Parse.history.navigate "/"


    handleUserPriviledges :->
      @listenTo Parse.User.current(), "change:network", => 
        # Remove the Access Denied callback
        Parse.history.off "route", @accessDenied

      # Take steps if user is not a part of the network.
      if Parse.User.current().get("network")
        @listenTo Parse.history, "route", @pendingApproval unless Parse.User.current().get("network").mgr
      else @listenTo Parse.history, "route", @accessDenied