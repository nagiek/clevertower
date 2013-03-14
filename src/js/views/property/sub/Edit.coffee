define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/sub/edit"
  'templates/property/form/_basic'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertyEditView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#content"
    
    events:
      'click .save'         : 'save'
      'click .remove'       : 'kill'
    
    initialize : ->
      @$el.append JST["src/js/templates/property/sub/edit.jst"](_.merge(property: @model, i18nProperty: i18nProperty, i18nCommon: i18nCommon))

      _.bindAll this, 'save'

      @on "property:save", =>
        @_clear()

      @on "property:cancel", =>
        @_clear()

    addOne : (image) =>
      view = new ImageView(model: image)
      @$photos.append view.render().el
        
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
          @$el.find('.alert-error').html(i18nProperty.errors.messages[error.message]).show()
          @$el.find('.error').removeClass('error')
          switch error.message
            when 'title_missing'
              @$el.find('#property-title-group').addClass('error') # Add class to Control Group
                
    _return : ->
      # $('#fileupload').fileupload('destroy');
      @remove()
      @undelegateEvents()
      delete this
      Parse.history.navigate "/properties/#{@model.id}"
      
    kill : ->
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        @model.destroy()
        @remove()
        @undelegateEvents()
        delete this
        Parse.history.navigate "/"
    