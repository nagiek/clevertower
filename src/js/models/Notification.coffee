define [
  'underscore'
  'backbone'
  'models/Profile'
  "i18n!nls/common"
], (_, Parse, Profile, i18nCommon) ->

  Notification = Parse.Object.extend "Notification",
    
    className: "Notification"

    defaults:
      read         : []
      clicked      : []
    
    unread : -> if @get("read") and _.contains @get("read"), Parse.User.current().id then false else true
    unclicked : -> if @get("clicked") and _.contains @get("clicked"), Parse.User.current().id then false else true
    hidden : -> if @get("hidden") and _.contains @get("hidden"), Parse.User.current().id then true else false

    isMemo : -> if @get("withAction") then false else true
    withAction : -> if @get("withAction") then true else false

    title : -> if @get("property") then @get("property").get("title") else @get("network").get("title")
    text : -> if @isMemo() then i18nCommon.notifications[@get("name")](@name(), @title()) else i18nCommon.notifications[@get("name")].invited(@name(), @title())
    name : -> if @get("profile") then @get("profile").name() else false

    accepted : -> i18nCommon.notifications[@get("name")].accept(@title())
    ignored : -> i18nCommon.notifications[@get("name")].ignore(@title())