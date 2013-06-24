define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Property'
  'models/Lease'
  'models/Inquiry'
  'views/listing/Summary'
  "i18n!nls/property"
  "i18n!nls/lease"
  "i18n!nls/listing"
  "i18n!nls/common"
  "underscore.inflection"
  'templates/lease/manage'
], ($, _, Parse, moment, Property, Lease, Inquiry, ListingView, i18nProperty, i18nLease, i18nListing, i18nCommon, inflection) ->

  class ManageLeaseView extends Parse.View

    el: '#main'
    
    initialize: (attrs) ->
      @baseUrl = "/manage"
      @listenTo @model, "change:start_date change:end_date", @renderHeader
      @listenTo Parse.User.current().get("unit"), "change:title", @renderHeader
      @listenTo Parse.Dispatcher, "user:logout", @clear
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: ->
      vars = 
        title:  Parse.User.current().get("property").get 'title'
        unitTitle: Parse.User.current().get("unit").get 'title'
        startDate: moment(@model.get "start_date").format("LL")
        endDate: moment(@model.get "end_date").format("LL")
        cover: Parse.User.current().get("property").cover 'profile'
        # Strings
        i18nProperty: i18nProperty
        i18nLease: i18nLease
        i18nCommon: i18nCommon
        i18nListing: i18nListing
        hasNetwork: Parse.User.current().get("network")
        baseUrl: @baseUrl
      
      @$el.html JST["src/js/templates/lease/manage.jst"](vars)
      @$("[rel=tooltip]").tooltip()
      @

    renderHeader: ->
      @$(".page-header .property-title").html Parse.User.current().get("property").get 'title'
      @$(".page-header .unit-title").html Parse.User.current().get("unit").get 'title'
      @$(".page-header .photo img").prop "src", Parse.User.current().get("property").cover 'profile'
      @$(".page-header .start-date").html moment(@model.get "start_date").format("LL")
      @$(".page-header .end-date").html moment(@model.get "end_date").format("LL")

    
    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this

    changeSubView: (path, params) =>
      
      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")
      
      action = if path then path.split("/") else Array('dashboard')
      if action.length is 1 or action[0] is "add"
        name = "views/lease/sub/#{action.join("/")}"
        @renderSubView name, property: Parse.User.current().get("property"), unit: Parse.User.current().get("unit"), onUnit: true, model: @model, params: params, forNetwork: false, baseUrl: @baseUrl
        
      else

        # Subnode view
        node = action[0][0].toUpperCase() + inflection.singularize[action[0]].substring(1) # units => Unit
        subid = action[1]
        subaction = if action[2] then "sub/#{action[2]}" else "show"
        name = "views/#{node}/#{subaction}"

        # Load the model if it exists.
        submodel = if @model[action[0]] then @model[action[0]].get(subid) else false

        if submodel
          @renderSubView name, property: Parse.User.current().get("property"), unit: Parse.User.current().get("unit"), onUnit: true, lease: @model, model: submodel, forNetwork: false, baseUrl: @baseUrl
        # Else get it from the server.
        else
          nodeType = switch action[0]
            when "inquiries" then Inquiry
          (new Parse.Query(nodeType)).get subid, success: (submodel) =>
            @renderSubView name, property: Parse.User.current().get("property"), unit: Parse.User.current().get("unit"), onUnit: true, lease: @model, model: submodel, forNetwork: false, baseUrl: @baseUrl

    renderSubView: (name, vars) =>
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass 'in'
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars).render()
        @$('.content').addClass 'in'

    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this