define [
  "jquery"
  "underscore"
  "backbone"
  "views/home/anon"
  "views/user/home"
  "i18n!nls/listing"
  "i18n!nls/common"
  "templates/home/index"
], ($, _, Parse, AnonHomeView, UserHomeView, i18nListing, i18nCommon) ->

  class HomeIndexView extends Parse.View

    el: "#main"

    initialize: (attrs) ->

      # Not worth the hassle of dealing with focused input boxes
      # $(window).on "keypress", @navigateIfArrow

      @on "view:change", =>
        @anonView.clear() if @anonView
        @userView.clear() if @userView
        @undelegateEvents()
        delete this

      Parse.Dispatcher.on "user:login", =>
        @anonView.clear() if @anonView
        @userView = new UserHomeView().render()

      Parse.Dispatcher.on "user:logout", =>
        @userView.clear() if @userView
        @anonView = new AnonHomeView().render()

    # Re-render the contents of the property item.
    render: =>
      if Parse.User.current() then @userView = new UserHomeView().render() else @anonView = new AnonHomeView().render()
      @


