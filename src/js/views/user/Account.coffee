define [
  "jquery"
  "underscore"
  "backbone"
  "views/helper/Alert"
  "views/user/sub/history" # This must be lowercase, or instanceof will break.
  "i18n!nls/common"
  "i18n!nls/user"
  "plugins/toggler"
  "templates/user/account"
], ($, _, Parse, Alert, UserHistoryView, i18nCommon, i18nUser) ->

  class UserAccountView extends Parse.View
    
    el: '#main'
        
    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params
    
    clear: =>
      @undelegateEvents()
      @stopListening()
      @subView.trigger "view:change" if @subView
      Parse.history.navigate "", true
      delete this

    render: ->      
      vars = 
        i18nUser: i18nUser
        i18nCommon: i18nCommon
      
      @$el.html JST["src/js/templates/user/account.jst"](vars)
      @

    changeSubView: (path, params) ->

      path = String path
      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")
      action = if path then path.split("/") else new Array('building')
      name = "views/user/sub/#{action[0]}"
      
      vars = params: params
      if action.length > 1 then vars.path = action.slice(1).join("/")

      if @subView and @subView instanceof UserHistoryView and action[0] is 'history'
        @subView.changeSubView vars.path, vars.params
      
      else
        # Load the model if it exists.
        @$("##{action[0]}-link").tab('show')
        @renderSubView name, vars


    renderSubView: (name, vars) ->
      @subView.trigger "view:change" if @subView
      require [name], (ProfileSubView) =>
        @subView = (new ProfileSubView(vars)).render()
