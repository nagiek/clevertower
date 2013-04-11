define [
  "jquery", 
  "backbone",
  "views/user/Menu"
  "views/network/Menu"
], ($, Parse, UserMenuView, NetworkMenuView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                            : "index"
      "network/set"                 : "networkSet"
      "network/:name"               : "networkShow"
      "users/:id"                   : "profileShow"
      "users/:id/edit"              : "profileEdit"
      "account/:category"           : "accountSettings"
      "*actions"                    : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      new UserMenuView(onNetwork: false).render()
      new NetworkMenuView()
      
      @on "route", => 
        @view.undelegateEvents()
        delete @view
      
      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).on "click", "a", (e) ->

        # Get the anchor href and protcol
        href = $(this).attr("href")
        
        return if href is "#" or not href?
        
        # protocol = location.protocol + "//"

        # Ensure the protocol is not part of URL, meaning its relative.
        # Stop the event bubbling to ensure the link will not cause a page refresh.
        # if href.slice(protocol.length) isnt protocol
        
        # If this is a relative link.
        if href.substring(0,1) is '/'
          e.preventDefault()

          # Note by using Backbone.history.navigate, router events will not be
          # triggered.  If this is a problem, change this to navigate on your
          # router.
          Parse.history.navigate href, true
        
    index: =>
      user = Parse.User.current()
      if user
        $('#main').html """
                        <h1>News Feed</h1>
                        <div class="row">
                          <div class="span8">

                          </div>
                          <div class="span4">
                            <!-- if user.get('type') is 'manager' then  -->
                            <ul class="nav nav-list"><li><a href="/network/set">Set up network</a></li></ul>
                          </div>
                        </div>
                        """
      else
        $('#main').html '<h1>Splash page</h1>'


    # User
    # --------------
    
    networkSet : ->
      if Parse.User.current()
        require ["views/network/New"], (NewNetworkView) =>              
          @view = new NewNetworkView(model: Parse.User.current().get("network")) # if !@view or @view !instanceof NewNetworkView
          @view.render()
      else
        @signupOrLogin()
    

    profileShow : (id) ->
      require ["models/Profile", "views/profile/Show"], (Profile, ShowProfileView) =>
        if Parse.User.current().profile and id is Parse.User.current().profile.id
          @view = new ShowProfileView model: Parse.User.current().profile, current: true
          @view.render()
        else
          (new Parse.Query(Profile)).get id,
          success: (obj) => 
            @view = new ShowProfileView model: obj, current: false
            @view.render()

    profileEdit : (id) ->
      require ["models/Profile", "views/profile/Edit"], (Profile, EditProfileView) =>
        if Parse.User.current().profile and id is Parse.User.current().profile.id
          @view = new EditProfileView model: Parse.User.current().profile, current: true
          @view.render()
        else
          (new Parse.Query(Profile)).get id,
          success: (obj) => 
            @view = new EditProfileView model: obj, current: false
            @view.render()
            
    accountSettings : (category) ->
      if Parse.User.current().authenticated()
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
        Parse.history.navigate "/"
        
    signupOrLogin: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'access-denied'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        Parse.history.navigate "/"