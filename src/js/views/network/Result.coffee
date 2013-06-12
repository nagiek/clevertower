define [
  "jquery"
  "underscore"
  "backbone"
  'models/Manager'
  'models/Network'
  'views/helper/Alert'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/network/result'
  'gmaps'
], ($, _, Parse, Manager, Network, Alert, i18nProperty, i18nCommon) ->

  class NetworkResultView extends Parse.View
  
    tagName: "li"
    className: "result clearfix lifted position-relative"

    events:
      "click .join": "join"
  
    initialize: (attrs) =>
      @listenTo @model, "remove", @clear

    render: =>
      vars =
        name:         @model.get("name")
        title:        @model.get("title")
        objectId:     @model.id
        publicUrl:    @model.publicUrl()
        i18nCommon:   i18nCommon
      
      @$el.html JST["src/js/templates/network/result.jst"](vars)
      @

    join: =>
      alert = new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.request_sent, type: 'success')
      
      manager = new Manager 
        status: 'pending'
        profile: Parse.User.current().get("profile")
        network: @model

      Parse.User.current().networkSetup(@model)

      Parse.Promise.when(manager.save(), Parse.User.current().save(network: @model))
      .then => @model.collection.trigger "network:join", @model
      , -> alert.setError i18nCommon.errors.unknown_error
    clear: =>
      @remove()
      @undelegateEvents()
      delete this