define [
  "jquery"
  "underscore"
  "backbone"
  "models/Network"
  "i18n!nls/property"
  "i18n!nls/common"
  "underscore.inflection"
  "templates/network/manage"
], ($, _, Parse, Network, i18nProperty, i18nCommon, inflection) ->

  class ManageNetworkView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    initialize: (attrs) ->

      _.bindAll this, 'updatePropertyCount', 'updateManagerCount', 'updateTenantCount', 'changeSubView', 'renderSubView'

      @model = Parse.User.current().get("network")

      @model.properties.on 'add reset', @updatePropertyCount
      @model.managers.on 'add reset', @updateManagerCount
      @model.tenants.on 'add reset', @updateTenantCount
      
      @model.on 'destroy', -> Parse.Dispatcher.trigger "user:logout"
      
      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: =>
      _.defaults @model.attributes, Network::defaults
      vars = _.merge @model.toJSON(),
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      # vars.title = network.get("name") unless vars.title
      @$el.html JST["src/js/templates/network/manage.jst"](vars)
      
      @$propertyCount = @$("#properties-link .count")
      @$managerCount = @$("#managers-link .count")
      @$tenantCount = @$("#tenants-link .count")

      @updatePropertyCount()
      @updateManagerCount()
      @updateTenantCount()

      @

    updatePropertyCount: -> @$propertyCount.html @model.properties.length
    updateManagerCount: -> @$managerCount.html @model.managers.length
    updateTenantCount: -> @$tenantCount.html @model.tenants.length


    changeSubView: (path, params) ->

      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")

      action = if path then path.split("/") else new Array('properties')
      name = "views/network/sub/#{action[0]}"
      
      vars = params: params, model: @model
      if action.length > 1 then vars.subaction = action.slice(1).join("/")
      
      # Load the model if it exists.
      @renderSubView name, vars

    renderSubView: (name, vars) ->
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass 'in'
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars)
        @$('.content').addClass 'in'
