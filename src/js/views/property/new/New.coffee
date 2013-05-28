define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/form'
  'templates/property/form_tenant'
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

        
    render : ->
      _.defaults(@model.attributes, Property::defaults)

      if Parse.User.current() and Parse.User.current().get("network")
        networkVars = 
          email: Parse.User.current().get("network").get("email")
          phone: Parse.User.current().get("network").get("phone")
          website: Parse.User.current().get("network").get("website")
        _.defaults(@model.attributes, networkVars)
        template = "src/js/templates/property/form.jst"
      else 
        template = "src/js/templates/property/form_tenant.jst"

      vars = 
        property: @model.attributes
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon


      @$el.html JST[template](vars)
      @

    clear : =>
      @undelegateEvents()
      @remove()
      delete this