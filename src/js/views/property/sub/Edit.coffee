define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  'views/helper/Alert'
  "i18n!nls/property"
  "i18n!nls/common"
  "plugins/toggler"
  "templates/property/sub/edit"
  'templates/property/_form'
], ($, _, Parse, Property, Alert, i18nProperty, i18nCommon) ->

  class PropertyEditView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: ".content"
    
    events:
      'click .save'         : 'save'
      'click .remove'       : 'kill'
    
    initialize : ->
      _.bindAll this, 'save'

      @on "view:change", @clear
      @on "property:save", @clear
      @on "property:cancel", @clear

    clear: (e) =>
      @undelegateEvents()
      delete this
      
    render : =>
      vars = 
        property: _.defaults(@model.attributes, Property::defaults)
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
      vars.property.id = @model.id
      @$el.html JST["src/js/templates/property/sub/edit.jst"](vars)
      @$('.toggle').toggler()
      @
        
    save : (e) ->
      e.preventDefault()
      attrs = @$('form').serializeObject().property
      @model.save attrs,
        success: (property) =>
          @trigger "property:save", property, this
          new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
        error: (property, error) =>
          @$el.find('.error').removeClass('error')
          new Alert(event: 'model-save', fade: false, message: i18nProperty.errors[error.message], type: 'error')
          switch error.message
            when 'title_missing'
              @$el.find('#property-title-group').addClass('error') # Add class to Control Group
      
    kill : ->
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        @model.destroy()
        @remove()
        Parse.history.navigate "/", true
        @clear()

    