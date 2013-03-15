define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "views/property/new/Map"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/new/map"
  "templates/property/new/wizard"
], ($, _, Parse, Property, GMapView, i18nProperty, i18nCommon) ->

  class PropertyWizardView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    
    el: '#form'
    
    state: 'address'
    
    events:
      'click .back'         : 'back'
      'click .next'         : 'next'
      'click .cancel'       : 'cancel'
    
    initialize : ->

      @model = new Property user: Parse.User.current()

      @$el
      .html(JST['src/js/templates/property/new/wizard.jst'](i18nCommon: i18nCommon))
      .find('.wizard-forms')
      .html(JST["src/js/templates/property/new/map.jst"](i18nProperty: i18nProperty, i18nCommon: i18nCommon))
      
      @map = new GMapView(wizard: this, marker: @model)

      @on "property:save", =>
        @remove()
        @undelegateEvents()
        delete this
        Parse.history.navigate '/'

      @on "wizard:cancel", =>
        @remove()
        @undelegateEvents()
        delete this
        Parse.history.navigate '/'

      _.bindAll this, 'next', 'back', 'cancel'

    next : (e) ->
      
      switch @state
        when 'address'
          center = @model.get "center"          
          return @$('.alert-error').html(i18nProperty.errors.invalid_address).show() if center._latitude is 0 and center._longitude is 0
          @state = 'property'
          Parse.Cloud.run(
            'CheckForUniqueProperty', { objectId: @model.id, center: center},
            success: =>
              require ["views/property/new/New", "templates/property/new/new"], (NewPropertyView) =>
                @$('.address-form').after '<form class="property-form span12"></form>'
                @form = new NewPropertyView(wizard: this, model: @model)
                
                # Animate
                @map.$el.animate left: "-150%", 500
                @form.$el.show().animate left: "0", 500
                @$('.back').prop disabled: false
                @$('.next').html(i18nCommon.actions.save)
                @$('.alert-error').hide()
            error: (error) =>
              @state = 'address'
              args = error.message.split ":"
              fn = args.pop()
              @$('.alert-error').html(i18nProperty.errors[fn](args[0])).show()
              # Errors always applied to search bar.
              @$('#address-search-group').addClass('error') # Add class to Control Group
          )
        when 'property'
          @model.save @form.$el.serializeObject().property,
            success: (property) =>
              @trigger "property:save", property, this
            error: (property, error) =>
              @$('.alert-error').html(i18nProperty.errors[error.message]).show()
              @$('.error').removeClass('error')
              switch error.message
                when 'title_missing'
                  @$('#property-title-group').addClass('error') # Add class to Control Group

    back : (e) ->
      return if @state is 'address'
      @state = 'address'
      @map.$el.animate left: "0%", 500
      @form.$el.animate left: "150%", 500, 'swing', ->
        @remove()
        delete this
      @$('.back').prop disabled: 'disabled'
      @$('.next').html(i18nCommon.actions.next)
      delete @form

    cancel : (e) ->
      @trigger "wizard:cancel", this
      @undelegateEvents()
      @$el.parent().find("section").show
      delete this

    remove : ->
      @$el.html ''

