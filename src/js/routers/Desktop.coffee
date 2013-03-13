define [
  "jquery", 
  "backbone",
  "views/app/Main"
  "views/address/Map"
], ($, Parse, AppView, NewAddressView) ->

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

      # Use delegation to avoid initial DOM selection and allow all matching elements to bubble
      $(document).delegate "a", "click", (e) ->

        # Get the anchor href and protcol
        href = $(this).attr("href")
        
        return if href is "#"
        
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
      new AppView()
      
    propertiesNew: ->
      require ["views/property/Manage"], (ManagePropertiesView) =>
        managePropertiesView = new ManagePropertiesView
        managePropertiesView.$el.find('#new-property').click()
        
    propertiesShow: (id, action) ->
      action ||= 'units'
      require ["models/Property", "views/property/Show"], (Property, PropertyView) =>
        $('#main').html '<div id="property"></div>'
        new Parse.Query("Property").get id, 
          success: (model) ->
            new PropertyView(model:model, action: action)