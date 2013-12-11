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
  'templates/property/form'
], ($, _, Parse, Property, Alert, i18nProperty, i18nCommon) ->

  class PropertyEditView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: ".content"
    
    events:
      'submit form'         : 'save'
      'click .remove'       : 'kill'
    
    initialize : ->

      @on "property:save", ->
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
      
      @on "property:sync", =>
        @$('button.save').button "reset"
      
      @listenTo @model, "invalid", (error) ->
        console.log error

        new Alert event: 'model-save', fade: false, message: i18nProperty.errors[error.message], type: 'danger'
        switch error.message
          when 'title_missing'
            @$('#property-title-group').addClass('has-error') # Add class to Control Group

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
        
    save : (e) =>
      e.preventDefault()
      @$('.has-error').removeClass('has-error')
      @$('button.save').button("loading")
      
      attrs = @model.scrub @$('form').serializeObject().property

      @model.save attrs,
        success: (property) =>
          @trigger "property:sync", property, this
          @trigger "property:save", property, this
        error: (property, error) =>
          @trigger "property:sync", property, this
          @model.trigger "invalid", error, this
      
    kill : ->
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        @model.destroy()
        @remove()
        Parse.history.navigate "/", true
        @clear()

    