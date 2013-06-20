define [
  "jquery"
  "underscore"
  "backbone"
  "models/Network"
  "views/helper/Alert"
  "i18n!nls/common"
  "i18n!nls/property"
  "templates/network/sub/edit"
  "templates/network/form"
], ($, _, Parse, Network, Alert, i18nCommon, i18nProperty) ->

  class EditNetworkView extends Parse.View
    
    events:
      'submit form'        : 'save'
    
    initialize : (attrs) ->
      
      @first = unless @model then true else false
      @model = new Network if @first

      @model.on "sync", (model) =>
        @$('.error').removeClass('error')
        @$('button.save').removeProp "disabled"

      @model.on "invalid", (error) =>
        @$('.name-group').addClass('error')
        msg = if error.message.indexOf(':') > 0
          args = error.message.split ":"
          fn = args.pop()
          i18nProperty.errors[fn](args[0])
        else
          i18nProperty.errors[error.message]
        new Alert(event: 'model-save', fade: false, message: msg, type: 'error')
                  
      @on "save:success", (model) =>
        Parse.User.current().set "network", model
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
        
        # if @first then 
        # require ["views/property/Manage"], (ManagePropertiesView) =>
        #   @undelegateEvents
        #   @view = new ManagePropertiesView if !@view or @view !instanceof ManagePropertiesView
        #   @view.render()
        #   delete this
        
      @render()
    
    save : (e) =>
      e.preventDefault()
      data = @$('form').serializeObject()

      @model.save data.network,
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
      
      @$el.html JST["src/js/templates/network/sub/edit.jst"](vars)
      @