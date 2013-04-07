define [
  "jquery", 
  "backbone",
  "views/user/UserMenu"
], ($, Parse, UserMenuView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                            : "index"
      "properties/new"              : "propertiesNew"
      "properties/:id"              : "propertiesShow"
      "properties/:id/*splat"       : "propertiesShow"
      "users/:id"                   : "profileShow"
      "users/:id/edit"              : "profileEdit"
      "account/:category"           : "accountSettings"
      "*actions"                    : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      new UserMenuView()
      
      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).on "click", "a", (e) ->

        # Get the anchor href and protcol
        href = $(this).attr("href")
        
        return if href is "#" or not href?
        
        protocol = @protocol + "//"

        # Ensure the protocol is not part of URL, meaning its relative.
        # Stop the event bubbling to ensure the link will not cause a page refresh.
        if href.slice(protocol.length) isnt protocol
          e.preventDefault()

          # Note by using Backbone.history.navigate, router events will not be
          # triggered.  If this is a problem, change this to navigate on your
          # router.
          Parse.history.navigate href, true
        
    index: =>
      user = Parse.User.current()
      if user
        if user.get("type") is "manager"
          require ["views/property/Manage"], (ManagePropertiesView) =>
            @view = new ManagePropertiesView if !@view or @view !instanceof ManagePropertiesView

            @view.render()
        else
          require ["views/property/Manage"], (ManagePropertiesView) =>
            @view = new ManagePropertiesView if !@view or @view !instanceof ManagePropertiesView
            @view.render()
      else
        $('#main').html '<h1>Cover page goes here</h1>'

    propertiesNew: =>
      if Parse.User.current()
        require ["views/property/Manage"], (ManagePropertiesView) =>
          @view = new ManagePropertiesView if !@view or @view !instanceof ManagePropertiesView
          @view.render()
          @view.newProperty()
      else
        @signupOrLogin()
        
    propertiesShow: (id, splat) =>
      if Parse.User.current()
        require ["views/property/Show"], (PropertyView) => 
          if !@view or @view !instanceof PropertyView
                  
            require ["models/Property", "collections/property/PropertyList"], (Property, PropertyList) => 
              if Parse.User.current().properties
                if model = Parse.User.current().properties.get id
                  combo = @deparamAction splat
                  vars = model:model, path: combo.path, params: combo.params
                
                  $('#main').html '<div id="property"></div>'
                  @view = new PropertyView(vars)
                else
                  new Parse.Query("Property").get id,
                  success: (model) =>
                    Parse.User.current().properties.add model
                    vars = @deparamAction splat
                    vars.model = model
                    $('#main').html '<div id="property"></div>'
                    @view = new PropertyView(vars)
                  error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL
                
              else
                if !Parse.User.current().properties then Parse.User.current().properties = new PropertyList
                new Parse.Query("Property").get id,
                success: (model) =>
                  Parse.User.current().properties.add model
                  vars = @deparamAction splat
                  vars.model = model
          
                  $('#main').html '<div id="property"></div>'
                  @view = new PropertyView(vars)
                error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL
                
          else
            vars = @deparamAction splat
            @view.changeSubView(vars.path, vars.params)
            
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