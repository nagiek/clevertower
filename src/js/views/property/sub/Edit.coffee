define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  'views/helper/Alert'
  "i18n!nls/property"
  "i18n!nls/common"
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
      @$el.html JST["src/js/templates/property/sub/edit.jst"](vars)
      @
        
    save : (e) ->
      e.preventDefault()
      if @unUploadedImages > 0
        $("#fileupload").fileupload('send').done(@_save())
      else
        @_save()
      
    _save : ->
      @model.save @$el.serializeObject().property,
        success: (property) =>
          @trigger "property:save", property, this
        error: (property, error) =>
          @$el.find('.error').removeClass('error')
          new Alert(event: 'property-save', fade: false, message: i18nProperty.errors[error.message], type: 'error')
          switch error.message
            when 'title_missing'
              @$el.find('#property-title-group').addClass('error') # Add class to Control Group
      
    kill : ->
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        @model.destroy()
        @remove()
        @undelegateEvents()
        delete this
        Parse.history.navigate "/"
    