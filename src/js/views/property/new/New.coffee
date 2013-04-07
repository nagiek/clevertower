define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/_form'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class NewPropertyView extends Parse.View

    el : ".property-form"

    initialize: (attrs) ->
      
      @wizard = attrs.wizard
      
      # object.listenTo(other, event, callback)   # Should be using this form
      @wizard.on "wizard:cancel", =>
        @undelegateEvents()
        @remove()
        delete @model
        delete this
      
      # object.listenTo(other, event, callback) 
      @wizard.on "property:save", =>
        @undelegateEvents()
        @remove()
        delete @model
        delete this
        
    render : ->
      @$el.html JST["src/js/templates/property/_form.jst"](property: @model, i18nProperty: i18nProperty, i18nCommon: i18nCommon)
      @