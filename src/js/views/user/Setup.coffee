define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/devise"
  "i18n!nls/user"
  "plugins/toggler"
  "templates/user/setup"
], ($, _, Parse, Alert, i18nCommon, i18nDevise, i18nUser) ->

  class SetupUserView extends Parse.View
    
    el: '#main'

    events:
      "click #user-type-group input" : "changeSubView"
    
    initialize : (attrs) ->
                  

    render: ->
      vars =
        type: Parse.User.current().get("type")
        i18nCommon: i18nCommon
        i18nDevise: i18nDevise
        i18nUser: i18nUser
      
      @$el.html JST["src/js/templates/user/setup.jst"](vars)
      @$('.toggle').toggler()

      # Have to reverse the type, as the event processes the one which is being clicked.
      type = if Parse.User.current().get("type") is "manager" then "tenant" else "manager"
      @changeSubView(currentTarget: defaultValue: type)
      @
      
    changeSubView: (e) ->
      type = if e.currentTarget.defaultValue is "manager" then "tenant" else "manager"
      if type is "manager"
        require ["views/network/New"], (NewNetworkView) => 
          view = new NewNetworkView(model: Parse.User.current().get("network"))
          @$(".content").removeClass("in").html(view.render().el).delay(150).addClass("in")
      else 
        require ["views/property/new/Wizard"], (PropertyWizard) =>

          @$(".content").removeClass("in")
          view = new PropertyWizard
          view.setElement ".content"
          view.render()
          @$(".content").delay(150).addClass("in")
          

          @listenTo view, "property:save", (property) =>
            
            # Add new property to collection
            Parse.User.current().save property: property,
            success: ->
            error: ->
