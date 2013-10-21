define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/user/sub/history'
], ($, _, Parse, i18nUser, i18nCommon) ->

  class UserHistoryView extends Parse.View
  
    el: "#history"
    
    initialize: (attrs) ->
      
      @subviews = {}

      @listenTo Parse.Dispatcher, "user:logout", @clear

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params
    
    clear: =>
      @stopListening()
      @undelegateEvents()
      _.each @subviews, (subview) -> subview.clear()
      delete this

    render: ->      
      vars = 
        i18nUser: i18nUser
        i18nCommon: i18nCommon
      
      @$el.html JST["src/js/templates/user/sub/history.jst"](vars)
      @

    changeSubView: (path, params) ->

      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")

      action = if path then path.split("/") else new Array('inquiries')
      name = "views/user/sub/history/#{action[0]}"
      
      vars = params: params
      if action.length > 1 then vars.path = action.slice(1).join("/")
      
      @$("##{action[0]}-link").tab('show')
      unless @subviews[name] 
        require [name], (ProfileSubView) => 
          @subviews[name] = (new ProfileSubView(vars)).render()


    