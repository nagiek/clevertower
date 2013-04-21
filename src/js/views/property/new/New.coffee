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

    tagName : "form"
    className: "property-form span8"

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
      networkVars = 
        email: @model.get("network").get("email")
        phone: @model.get("network").get("phone")
        website: @model.get("network").get("website")
      _.defaults(@model.attributes, Property::defaults)
      _.defaults(@model.attributes, networkVars)
      vars = 
        property: @model.attributes
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/property/_form.jst"](vars)
      @