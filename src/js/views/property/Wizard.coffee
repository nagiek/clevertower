define [
  "jquery"
  "underscore"
  "backbone"
  "models/Address"
  "models/Property"
  "views/address/Map"
  "i18n!nls/address"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/address/map"
  "templates/property/wizard"
], ($, _, Parse, Address, Property, GMapView, i18nAddress, i18nProperty, i18nCommon) ->

  class PropertyWizardView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#form"
    
    state: 'address'
    
    events:
      'click .back'         : 'back'
      'click .next'         : 'next'
      'click .cancel'       : 'cancel'
    
    initialize : ->
      @address = new Address
      @property = new Property address: @address, user: Parse.User.current()

      @$el.html   JST["src/js/templates/address/map.jst"](i18nAddress: i18nAddress, i18nCommon: i18nCommon)
      @$el.append JST["src/js/templates/property/wizard.jst"](i18nCommon: i18nCommon)
      
      @map = new GMapView(wizard: this, address: @address)
      
      @on "property:save", =>
        @remove()
        @undelegateEvents()
        # delete @map
        # delete @form
        delete this
        Parse.history.navigate '/'

      @on "wizard:cancel", =>
        @remove()
        @undelegateEvents()
        # delete @map
        # delete @form
        delete this
        Parse.history.navigate '/'

      
      _.bindAll this, 'next', 'back', 'cancel'
      @render()

    next : (e) ->
      
      switch @state
        when 'address'
          @address.save
            # The object was saved successfully.
            success: (address) =>
              
              @state = 'property'
              
              # @property.set address, @address # Should be in the model section.
              require ["views/property/New", "templates/property/new"], (NewPropertyView) =>

                @$el.find('.address-form').after '<form class="property-form"></form>'
                @form = new NewPropertyView(wizard: this, model: @property)

                # Animate
                @map.$el.animate left: "-150%", 500
                @form.$el.show().animate left: "0", 500
                @$el.find('.back').prop disabled: false
                @$el.find('.next').html(i18nCommon.actions.save)
                
            # The save failed.
            # error is a Parse.Error with an error code and description.
            error: (address, error) =>
              @$el.find('.alert-error').html(i18nAddress.errors.messages[error.message]).show()
              @$el.find('.error').removeClass('error') # Strip old errors.
              switch error.message
                when 'invalid_address'
                  @$el.find('#address-search-group').addClass('error') # Add class to Control Group

                                  
        when 'property'
          @property.save @form.$el.serializeObject().property,
            success: (property) =>
              @trigger "property:save", property, this
            error: (property, error) =>
              @$el.find('.alert-error').html(i18nProperty.errors.messages[error.message]).show()
              @$el.find('.error').removeClass('error')
              switch error.message
                when 'title_missing'
                  @$el.find('#property-title-group').addClass('error') # Add class to Control Group



    back : (e) ->
      @state = 'address'
      @map.$el.animate left: "0%", 500
      @form.$el.animate left: "150%", 500, 'swing', ->
        @remove()
        delete this
      @$el.find('.back').prop disabled: 'disabled'
      @$el.find('.next').html(i18nCommon.actions.next)
      delete @form

    cancel : (e) ->
      @trigger "wizard:cancel", this
      @undelegateEvents()
      @$el.hide()
      @$el.parent().find("section").show
      delete this

    render : ->
      @map.$el.show()
