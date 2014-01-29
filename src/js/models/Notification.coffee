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

    text : ->
      object = @object()
      if object and @get("name") is "like" then object = i18nCommon.functions.possessive object
      if @isMemo() then i18nCommon.notifications[@get("name")](@subject(), object) else i18nCommon.notifications[@get("name")].invited(@subject(), object)
    subject : -> if @get("subject") then @get("subject").name() else false
    object : ->
      if @get("name").indexOf("inquiry") isnt -1 or @get("name").indexOf("invitation") isnt -1
        if @get("name").indexOf("network") isnt -1 then @get("network").name() else @get("property").get("profile").name()
      else if @get("object") 
        if @get("object").id is Parse.User.current().get("profile").id then i18nCommon.nouns.you else @get("object").name() 

    accepted : -> i18nCommon.notifications[@get("name")].accept(@subject())
    ignored : -> i18nCommon.notifications[@get("name")].ignore(@subject())