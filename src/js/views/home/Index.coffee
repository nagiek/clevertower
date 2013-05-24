define [
  "jquery"
  "underscore"
  "backbone"
  "views/home/anon"
  "views/activity/index"
  "i18n!nls/listing"
  "i18n!nls/common"
  "templates/home/index"
], ($, _, Parse, AnonHomeView, ActivityIndexView, i18nListing, i18nCommon) ->

  class HomeIndexView extends Parse.View

    el: "#main"

    initialize: (attrs) ->

      # Not worth the hassle of dealing with focused input boxes
      # $(window).on "keypress", @navigateIfArrow

      @on "view:change", =>
        @anonView.clear() if @anonView
        @searchView.clear() if @searchView
        @undelegateEvents()
        delete this

      Parse.Dispatcher.on "user:login", =>
        @anonView.clear() if @anonView
        @searchView = new ActivityIndexView(params: {})

      Parse.Dispatcher.on "user:logout", =>
        @searchView.clear() if @searchView
        @anonView = new AnonHomeView().render()

    # Re-render the contents of the property item.
    render: =>
      if Parse.User.current() then @searchView = new ActivityIndexView(params: {}) else @anonView = new AnonHomeView().render()
      @