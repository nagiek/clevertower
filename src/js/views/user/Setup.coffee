define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  "views/network/New"
  "views/property/new/Wizard"
  "views/notification/Setup"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  "plugins/toggler"
  "templates/user/presetup"
  "templates/user/setup"
], ($, _, Parse, NotificationList, NewNetworkView, PropertyWizard, NotificationView, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class SetupUserView extends Parse.View
    
    el: '#main'

    events:
      "click #user-type-group input" : "changeSubView"
      "click .accept" : "readyToMoveOn"
      "click .skip-this-step" : "skipThisStep"

    initialize : (attrs) ->
      @listenTo Parse.Dispatcher, "user:logout", -> Parse.history.navigate("/", true)
      @skip = false
    
    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this

    skipThisStep: (e) =>
      e.preventDefault()
      @skip = true
      @render()

    readyToMoveOn: => @$(".done").removeProp "disabled"

    render: =>

      # Check if the user has any outstanding requests and present them. 
      if @skip or Parse.User.current().notifications.visibleWithAction().length is 0

        type = Parse.User.current().get("user_type") || "tenant"
        vars =
          type: type
          i18nCommon: i18nCommon
          i18nDevise: i18nDevise
          i18nUser: i18nUser
        @$el.html JST["src/js/templates/user/setup.jst"](vars)
        @$('.toggle').toggler()

        # Have to reverse the type, as the event processes the one which is being clicked.
        defaultValue = if type is "manager" then "tenant" else "manager"
        @changeSubView currentTarget: defaultValue: defaultValue        

      # Go to user setup.
      else 
        vars =
          i18nCommon: i18nCommon
          i18nUser: i18nUser
        @$el.html JST["src/js/templates/user/presetup.jst"](vars)
        @$list = @$("table.content tbody")
        Parse.User.current().notifications.each @addOne
      @

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (n) =>
      if n.withAction() and n.unclicked()
        view = new NotificationView(model: n)
        @$list.append view.render().el

    hideIntro: => @$("header").removeClass "in"
    showIntro: => @$("header").addClass "in"

    changeSubView: (e) ->

      type = if e.currentTarget.defaultValue is "manager" then "tenant" else "manager"
      if type is "manager"
        view = new NewNetworkView(model: Parse.User.current().get("network"))
        @$(".content").removeClass("in").html(view.render().el).delay(150).addClass("in")
      else 
        @$(".content").removeClass("in")
        view = new PropertyWizard forNetwork: false
        @listenTo view, "view:advance", @hideIntro
        @listenTo view, "view:retreat", @showIntro

        view.setElement ".content"
        view.render()
        @$(".content").delay(150).addClass("in")
