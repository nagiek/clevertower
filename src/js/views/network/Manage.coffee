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

      @model = Parse.User.current().get("network")

      @listenTo @model.properties, 'add reset', @updatePropertyCount
      @listenTo @model.managers, 'add reset', @updateManagerCount
      @listenTo @model.listings, 'add reset', @updateListingCount
      @listenTo @model.tenants, 'add reset', @updateTenantCount
      
      @listenTo @model, 'destroy', -> Parse.Dispatcher.trigger "user:logout"
      
      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: =>
      _.defaults @model.attributes, Network::defaults
      name = @model.get("name")
      vars = 
        title: @model.get("title")
        name: name
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
        public_url: "//" + location.host.split(".").slice(1).join(".") + "/networks/#{name}" 
      # vars.title = network.get("name") unless vars.title
      @$el.html JST["src/js/templates/network/manage.jst"](vars)
      
      @updatePropertyCount()
      @updateManagerCount()
      @updateTenantCount()
      @updateListingCount()

      @

    updatePropertyCount: => @$("#properties-link .count").html @model.properties.length
    updateManagerCount: => @$("#managers-link .count").html @model.managers.length
    updateListingCount: => @$("#listings-link .count").html @model.listings.length
    updateTenantCount: => @$("#tenants-link .count").html @model.tenants.length

    changeSubView: (path, params) =>

      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")

      action = if path then path.split("/") else new Array('properties')
      name = "views/network/sub/#{action[0]}"
      
      vars = params: params, model: @model
      if action.length > 1 then vars.subaction = action.slice(1).join("/")
      
      # Load the model if it exists.
      @renderSubView name, vars

    renderSubView: (name, vars) =>
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass('in').empty()
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars)
        @$('.content').addClass('in').html @subView.render().el
