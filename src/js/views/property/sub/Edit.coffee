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
        new Alert(event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success')
      
      @on "property:sync", ->
        @$('button.save').removeProp('disabled')
      
      @model.on "invalid", (error) ->
        console.log error

        new Alert(event: 'model-save', fade: false, message: i18nProperty.errors[error.message], type: 'error')
        switch error.message
          when 'title_missing'
            @$el.find('#property-title-group').addClass('error') # Add class to Control Group

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
      @$('.error').removeClass('error')
      @$('button.save').prop('disabled', 'disabled')
      
      attrs = @$('form').serializeObject().property

      bools = ['electricity'
        'furniture'
        'gas'
        'heat'
        'hot_water'
        # Included
        'air_conditioning'
        'back_yard'
        'balcony'
        'cats_allowed'
        'concierge'
        'dogs_allowed'
        'doorman'
        'elevator'
        'exposed_brick'
        'fireplace'
        'front_yard'
        'gym'
        'laundry'
        'indoor_parking'
        'outdoor_parking'
        'pool'
        'sauna'
        'wheelchair'
        # Private
        'public'
        'anon'
      ]

      console.log attrs
      debugger

      _.each bools, (attr) -> 
        # Have to return true because returning false breaks the _.each loop.
        attrs[attr] = if attrs[attr] is "on" or attrs[attr] is "1" then true else false
        true

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

    