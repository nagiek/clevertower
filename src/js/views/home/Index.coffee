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

    # Re-render the contents of the property item.
    render: =>
      if Parse.User.current() then @searchView = new ActivityIndexView(params: {}).render() else @anonView = new AnonHomeView().render()
      @