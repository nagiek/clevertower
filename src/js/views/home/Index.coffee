define [
  "jquery"
  "underscore"
  "backbone"
  "views/listing/index"
  "views/home/anon"
  "views/user/home"
  "i18n!nls/listing"
  "i18n!nls/common"
  "templates/home/index"
], ($, _, Parse, ListingIndexView, AnonHomeView, UserHomeView, i18nListing, i18nCommon) ->

  class HomeIndexView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    initialize: (attrs) ->

      _.bindAll this, 'render'
      @attrs = attrs || {}

      @on "view:change", =>
        @anonView.undelegateEvents()
        @userView.undelegateEvents()
        delete @anonView
        delete @userView

      Parse.Dispatcher.on "user:login", =>
        @anonView.undelegateEvents()
        delete @anonView
        @userView = new UserHomeView

      Parse.Dispatcher.on "user:logout", =>
        @userView.undelegateEvents()
        delete @userView
        @anonView = new AnonHomeView
      

    # Re-render the contents of the property item.
    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nListing: i18nListing
      @$el.html JST["src/js/templates/home/index.jst"](vars)

      if Parse.User.current() then @userView = new UserHomeView().render() else @anonView = new AnonHomeView().render()
      new ListingIndexView(@attrs)

      @
