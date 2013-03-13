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