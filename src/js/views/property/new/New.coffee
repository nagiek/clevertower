define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/form'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class NewPropertyView extends Parse.View

    tagName : "form"
    className: "property-form span12"

    initialize: (attrs) ->
      
      @wizard = attrs.wizard
      
      @listenTo @wizard, "wizard:cancel", @clear
      @listenTo @wizard, "property:save", @clear
      @listenTo @wizard, "lease:save", @clear

        
    render : ->

      # Merge in defaults.
      _.defaults @model.attributes, Property::defaults
      if Parse.User.current() and Parse.User.current().get("network")
        _.defaults @model.attributes,
          email: Parse.User.current().get("network").get("email")
          phone: Parse.User.current().get("network").get("phone")
          website: Parse.User.current().get("network").get("website")

      vars = 
        property: @model.attributes
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/property/form.jst"](vars)
      @

    clear : =>
      @undelegateEvents()
      @remove()
      delete this