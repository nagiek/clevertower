define [
  "jquery"
  "underscore"
  "backbone"
  "views/inquiry/own"
  "i18n!nls/property"
  "i18n!nls/lease"
  "i18n!nls/user"
  "i18n!nls/common"
  "templates/profile/sub/accommodation"
], ($, _, Parse, InquiryView, i18nProperty, i18nLease, i18nUser, i18nCommon) ->

  class ProfileAccommodationView extends Parse.View
  
    el: "#accommodation"
    
    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @current = attrs.current

    clear: ->
      @remove()
      @undelegateEvents()
      delete this
      
    render: ->

      vars =
        property: if Parse.User.current().get("property") then Parse.User.current().get("property").toJSON() else false
        lease: if Parse.User.current().get("lease") then Parse.User.current().get("lease").toJSON() else false
        i18nProperty : i18nProperty
        i18nUser: i18nUser
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/profile/sub/accommodation.jst"](vars)
      @
