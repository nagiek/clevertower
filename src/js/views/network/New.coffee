define [
  "jquery"
  "underscore"
  "backbone"
  "collections/NetworkResultsList"
  "models/Network"
  "views/network/Result"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/property"
  "templates/network/new"
  "templates/network/form"
], ($, _, Parse, NetworkResultsList, Network, NetworkView, Alert, i18nCommon, i18nProperty) ->

  class NewNetworkView extends Parse.View
    
    events:
      'click .nav a'                  : 'showTab'
      'submit form#new-network-form'  : 'save'
      'click #network-search'         : 'search'
    
    initialize : (attrs) ->
      
      @model = new Network unless @model
      @results = new NetworkResultsList

      @listenTo @results, "reset", @addAll
      @listenTo @results, "network:join", => 
        Parse.User.current().networkSetup().then ->
          Parse.history.navigate "inside", true

      # Only do this on 'invalid', as we will reload the page 
      # for the user and we don't want them getting antsy
      # @model.on "sync", (model) =>
      #   @$('.error').removeClass('error')
      #   @$('button.save').removeProp "disabled"

      @listenTo @model, "invalid", (error) =>
        console.log error
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"
        @$('.name-group').addClass('error')
        msg = if error.message.indexOf(':') > 0
          args = error.message.split ":"
          fn = args.pop()
          i18nProperty.errors[fn](args[0])
        else
          i18nProperty.errors[error.message]
        new Alert event: 'model-save', fade: false, message: msg, type: 'danger'
          
                  
      @on "save:success", (model) =>
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        Parse.User.current().set "network", @model

        Parse.User.current().networkSetup().then ->
          if Parse.User.current().get("property") then Parse.User.current().get("property").set("network", @model).save()
          Parse.history.navigate "inside", true

        # Navigate after a second.
        # domain = "#{location.protocol}//#{model.get("name")}.#{location.host}"
        # setTimeout window.location.replace domain, 1000
    
    showTab: (e) -> 
      e.preventDefault()
      $(e.currentTarget).tab('show')

    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this

    # Results Handling
    # ----------------

    addOne: (n) =>
      view = new NetworkView model: n
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: =>
      @$list.html ""
      unless @results.length is 0
        @results.each @addOne
      else
        @$list.html """
                    <li class='empty text-center font-large'>
                      <p>#{i18nProperty.search.no_network_results}</p>
                      <p><small>#{i18nProperty.search.private_network}</small></p>
                    </li>
                    """

    search: (e) =>
      e.preventDefault()
      @results.setName @$("#network-search-input").val()
      @results.fetch()

    # Create Logic
    # ----------------

    save : (e) =>
      e.preventDefault()
      data = @$('form').serializeObject()
      @$('button.save').prop "disabled", "disabled"

      attrs = @model.scrub data.network

      @model.save attrs,
      success: (model) =>
        @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
        @trigger "save:success", model, this
      error: (model, error) =>
        @model.trigger "sync", model # This is triggered automatically in Backbone, but not Parse.
        @model.trigger "invalid", error

    render: ->
      vars = 
        network: _.defaults(@model.attributes, Network::defaults)
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      
      @$el.html JST["src/js/templates/network/new.jst"](vars)

      @$list = @$("#network-search-results")

      @