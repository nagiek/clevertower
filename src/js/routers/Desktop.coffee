define [
  "jquery", 
  "backbone",
  "views/user/User"
], ($, Parse, UserView) ->

  class DesktopRouter extends Parse.Router
    routes:
      ""                          : "index"
      "properties/new"            : "propertiesNew"
      # "properties/:id/add/(:action)" : "propertiesAddSub"
      "properties/:id"            : "propertiesShow"
      "properties/:id/:action"    : "propertiesShow"
      "*actions"                  : "index"

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
        
    index: ->
      require ["views/network/Manage"], (ManageNetworkView) =>
        new ManageNetworkView

    propertiesNew: ->
      require ["views/property/Manage"], (ManagePropertiesView) =>
        managePropertiesView = new ManagePropertiesView
        managePropertiesView.$el.find('#new-property').click()
        
    propertiesShow: (id, action) ->
      action ||= 'units'
      new Parse.Query("Property").get id,
        success: (model) ->
          $('#main').html '<div id="property"></div>'
          require ["views/property/Show"], (PropertyView) -> new PropertyView(model:model, action: action)
        error: => @accessDenied()
        
    accessDenied: ->
      require ["views/helper/Alert", 'i18n!nls/common'], (Alert, i18nCommon) -> 
        new Alert
          event:    'access-denied'
          type:     'error'
          fade:     true
          heading:  i18nCommon.errors.access_denied
          message:  i18nCommon.errors.no_permission
        Parse.history.navigate "/"