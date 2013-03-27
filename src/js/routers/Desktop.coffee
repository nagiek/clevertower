define [
  "jquery", 
  "backbone",
  "views/user/User"
], ($, Parse, UserView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                            : "index"
      "properties/new"              : "propertiesNew"
      "properties/:id"              : "propertiesShow"
      # "properties/:id/add/:model"   : "propertiesAddSub"
      "properties/:id/*action"      : "propertiesShow"
      "*actions"                    : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
      
      new UserView

      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).delegate "a", "click", (e) ->

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
    
    deparam : (querystring) ->
      # remove any preceding url and split
      querystring = querystring.substring(querystring.indexOf('?')+1).split('&')
      params = {}
      d = decodeURIComponent
      # march and parse
      for combo in querystring
        pair = combo.split('=')
        params[d(pair[0])] = d(pair[1])
      params
        
    index: ->
      require ["views/network/Manage"], (ManageNetworkView) =>
        new ManageNetworkView

    propertiesNew: ->
      require ["views/property/Manage"], (ManagePropertiesView) =>
        managePropertiesView = new ManagePropertiesView
        managePropertiesView.$el.find('#new-property').click()
        
    propertiesShow: (id, action) ->
      console.log 'propertiesShow'
      action ||= 'units'

      # Split the querystring
      if action.indexOf("?") > 0
        combo = action.split("?")
        action = combo[0]
        params = @deparam combo[1]
        
      require ["models/Property", "views/property/Show"], (Property, PropertyView) => 
        new Parse.Query("Property").get id,
          success: (model) ->
            $('#main').html '<div id="property"></div>'            
            vars = model:model, action: action
            vars.params = params if params
            new PropertyView(vars)
          error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL

    # propertiesAddSub: (id, node) ->
    #   require ["models/#{node}", "views/property/add/#{node}"], (Property, AddSubPropertyView) => 
    #     new Parse.Query("Property").get id,
    #       success: (model) ->
    #         $('#main').html '<div id="property"></div>'
    #         new AddSubPropertyView(property:property)
    #       error: (object, error) => @accessDenied() # if error.code is Parse.Error.INVALID_ACL

      
    accessDenied: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'access-denied'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        Parse.history.navigate "/"