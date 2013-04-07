define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "views/helper/Alert"
  "views/property/new/Map"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/new/map"
  "templates/property/new/wizard"
], ($, _, Parse, Property, Alert, GMapView, i18nProperty, i18nCommon) ->

  class PropertyWizardView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    
    el: '.wizard'
    
    state: 'address'
    
    events:
      'click .back'         : 'back'
      'click .next'         : 'next'
      'click .cancel'       : 'cancel'
    
    initialize : ->

      _.bindAll this, 'next', 'back', 'cancel', 'render'

      @model = new Property user: Parse.User.current()

      @model.on "invalid", (error) =>
        @state = 'address'
        msg = if error.message.indexOf(":") > 0  
          args = error.message.split ":"
          fn = args.pop()
          i18nProperty.errors[fn](args[0])
        else
          i18nProperty.errors[error.message]

        switch error.message
          when 'title_missing' then @$('#property-title-group').addClass('error') # Add class to Control Group
          else @$('#address-search-group').addClass('error') # Add class to Control Group
        
        new Alert event: 'model-save', fade: false, message: msg, type: 'error'

      @on "address:validated", =>
        @state = 'property'
        require ["views/property/new/New", "templates/property/new/new"], (NewPropertyView) =>

          @form = new NewPropertyView(wizard: this, model: @model)
          @map.$el.after @form.render().el
          
          # Animate
          @map.$el.animate left: "-150%", 500
          @form.$el.animate left: "0", 500
          @$('.back').prop disabled: false
          @$('.next').html(i18nCommon.actions.save)

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

    render : ->
      @$el.html(JST['src/js/templates/property/new/wizard.jst'](i18nCommon: i18nCommon))
      @map = new GMapView(wizard: this, marker: @model).render()
      @

    next : (e) ->
      @$('.error').removeClass('error')
      switch @state
        when 'address'
          center = @model.get "center"
          return @model.trigger "invalid", {message: 'invalid_address'} if center._latitude is 0 and center._longitude is 0
          Parse.Cloud.run 'CheckForUniqueProperty', 
            { objectId: @model.id, center: center },
            success: =>       @trigger "address:validated"
            error: (error) => @model.trigger "invalid", error
              
        when 'property'
          @model.save @form.$el.serializeObject().property,
            success: (property) =>        @trigger "property:save", property, this
            error: (property, error) =>   @model.trigger "invalid", error

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

