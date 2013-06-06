define [
  "jquery"
  "underscore"
  "backbone"
  "models/Profile"
  "views/profile/sub/Activities"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, Profile, ActivityView, i18nUser, i18nCommon) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"
    
    initialize: (attrs) ->

      @current = attrs.current

      @listenTo Parse.Dispatcher, "user:logout", @switchToPublic

      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params
    
    switchToPublic: =>
      if @subView !instanceof ActivityView
        @current = false
        Parse.history.navigate "/users/#{@model.id}"
        @changeSubView()


    render: ->      
      vars = _.merge @model.toJSON(),
        cover: @model.cover 'profile'
        name: @model.name()
        i18nUser: i18nUser
        i18nCommon: i18nCommon
        current: @current
        createdAt: moment(@model.createdAt).format("L")
      
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/profile/show.jst"](vars)

      @

    changeSubView: (path, params) ->

      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")

      action = if path then path.split("/") else new Array('activities')
      name = "views/profile/sub/#{action[0]}"
      
      vars = params: params, model: @model, current: @current
      if action.length > 1 then vars.path = action.slice(1).join("/")
      
      # Load the model if it exists.
      @$("##{action[0]}-link").tab('show')
      @renderSubView name, vars


    renderSubView: (name, vars) ->
      @subView.trigger "view:change" if @subView
      require [name], (ProfileSubView) =>
        @subView = (new ProfileSubView(vars)).render()
