define [
  "jquery", 
  "backbone",
  "views/app/Main"
  "views/address/Map"
], ($, Parse, AppView, NewAddressView) ->

  class AppRouter extends Parse.Router
    routes:
      "address/new"         : "addressNew"
      ""                    : "index"
      "*actions"            : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
        
    index: ->
      new AppView()
      
    addressNew: ->
      require ["views/property/Manage"], (ManagePropertiesView) =>
        managePropertiesView = new ManagePropertiesView
        managePropertiesView.$el.find('#new-property').click()