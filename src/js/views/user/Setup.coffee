define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NotificationList"
  "views/notification/Setup"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  "plugins/toggler"
  "templates/user/respond"
  "templates/user/setup"
], ($, _, Parse, NotificationList, NotificationView, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class SetupUserView extends Parse.View
    
    el: '#main'

    events:
      "click #user-type-group input" : "changeSubView"
      "click .accept" : "readyToMoveOn"
      "click .skip-this-step" : "skipThisStep"
      "click .done" : "done"

    initialize : (attrs) ->
      @skip = false

    skipThisStep: =>
      @skip = true
      @render()

    readyToMoveOn: =>
      @$(".done").removeProp "disabled"

    done: =>
      @skip = true
      @render()

    render: =>
      
      # Check if the user has any outstanding requests and present them. 
      unless @skip or Parse.User.current().notifications.unclickedWithAction().length is 0
        vars =
          i18nCommon: i18nCommon
          i18nUser: i18nUser
        @$el.html JST["src/js/templates/user/respond.jst"](vars)
        @$list = @$("table.content tbody")
        Parse.User.current().notifications.each @addOne

      # Go to user setup.
      else 
        type = if Parse.User.current().get("user_type") then Parse.User.current().get("user_type") else "tenant"
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
      @

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (n) =>
      if n.withAction() and n.unclicked()
        view = new NotificationView(model: n)
        @$list.append view.render().el
      
    changeSubView: (e) ->
      type = if e.currentTarget.defaultValue is "manager" then "tenant" else "manager"
      if type is "manager"
        require ["views/network/New"], (NewNetworkView) => 
          view = new NewNetworkView(model: Parse.User.current().get("network"))
          @$(".content").removeClass("in").html(view.render().el).delay(150).addClass("in")
      else 
        require ["views/property/new/Wizard"], (PropertyWizard) =>

          @$(".content").removeClass("in")
          view = new PropertyWizard forNetwork: false
          view.setElement ".content"
          view.render()
          @$(".content").delay(150).addClass("in")
          

          @listenTo view, "property:save", (property) =>
            
            # Add new property to collection
            Parse.User.current().save property: property,
            success: ->
            error: ->
