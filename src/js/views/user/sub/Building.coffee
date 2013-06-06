define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/lease"
  "i18n!nls/user"
  "templates/user/sub/building"
  "templates/profile/thumbnail"
], ($, _, Parse, i18nCommon, i18nProperty, i18nLease, i18nUser) ->

  class BuildingUserView extends Parse.View
    
    el: '#building'

    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @listenTo Parse.User.current(), "change:property", @prepProperty
      
      @prepProperty() if Parse.User.current().get("property")

    prepProperty: ->
      Parse.User.current().get("property").prep("tenants")
      @listenTo Parse.User.current().get("property").tenants, "reset", @addAll

    clear: ->
      @remove()
      @undelegateEvents()
      delete this

    render: =>

      vars =
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
        i18nLease: i18nLease
        i18nUser: i18nUser
        property: if Parse.User.current().get("property") then Parse.User.current().get("property").toJSON() else false
        unit: if Parse.User.current().get("unit") then Parse.User.current().get("unit").toJSON() else false
        lease: if Parse.User.current().get("lease") then Parse.User.current().get("lease").toJSON() else false
      
      @$el.html JST["src/js/templates/user/sub/building.jst"](vars)

      @$tList = @$("#tenants")
      @$rList = @$("#roommates")

      if Parse.User.current().get("property")
        if Parse.User.current().get("property").tenants.length > 0 then @addAll 
        else Parse.User.current().get("property").tenants.fetch()
      @

    addAll: =>

      @$tList.html ""
      @$rList.html ""

      # Check to see if we have more than one tenant for each lsit
      hasR = Parse.User.current().get("property").tenants.find (t) -> t.get("lease").id is Parse.User.current().get("lease").id
      hasT = Parse.User.current().get("property").tenants.find (t) -> t.get("lease").id isnt Parse.User.current().get("lease").id

      if hasT then @$tList.append "<li class='empty'>#{i18nLease.empty.tenants}</li>"
      if hasR then @$rList.append "<li class='empty'>#{i18nLease.empty.roommates}</li>"
      Parse.User.current().get("property").tenants.each @addOne

    addOne: (t) =>
      vars = 
        name: t.get("profile").name()
        objectId: t.get("profile").id
        url: t.get("profile").cover("thumb")
        current_user: t.get("profile").id is Parse.User.current().get("profile").id
        i18nCommon: i18nCommon

      if t.get("lease").id is Parse.User.current().get("lease").id
        @$tList.append "<li class='profile'>" + JST["src/js/templates/profile/thumbnail.jst"](vars) + "</li>"
      else @$rList.append "<li class='profile'>" +JST["src/js/templates/profile/thumbnail.jst"](vars) + "</li>"