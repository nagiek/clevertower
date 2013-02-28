define [
  "jquery"
  "underscore"
  "backbone"
  'collections/property/PropertyList',
  "models/Property"
  "views/property/summary"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/property/manage"
], ($, _, Parse, PropertyList, Property, PropertyView, i18nProperty, i18nCommon) ->

  class ManagePropertiesView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    events:
      'click #new-property' : "newProperty"
    
    initialize : ->
      @$el.html JST["src/js/templates/property/manage.jst"](i18nProperty: i18nProperty)
      
      _.bindAll this, 'newProperty'
      
      @$list = @$el.find("ul#property-list")
      
      # Create our collection of Properties
      @properties = new PropertyList
      
      # Setup the query for the collection to look for properties from the current user
      @properties.query = new Parse.Query(Property)
      @properties.query.equalTo "user", Parse.User.current()
      @properties.bind "add", @addOne
      @properties.bind "reset", @addAll
      @properties.bind "all", @render
    
      # Fetch all the property items for this user
      @properties.fetch()
      
      @render()
      
    render: ->
      # done = @properties.done().length
      # remaining = @properties.remaining().length
      # @$("#property-stats").html @statsTemplate(
      #   total: @properties.length
      #   done: done
      #   remaining: remaining
      # )
      # @delegateEvents()
      # @allCheckbox.checked = not remaining
    
    # Add a single property item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (property) =>
      view = new PropertyView(model: property)
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      @properties.each @addOne
    
    newProperty : ->

      require ["views/property/Wizard"], (PropertyWizard) =>
        @$el.find("#new-property").prop disabled: "disabled"
        @$el.find("section").hide()
        propertyWizard = new PropertyWizard
        Parse.history.navigate "/address/new"

        propertyWizard.on "wizard:cancel", (property) =>
          
          # Reset form
          @$el.find("#new-property").removeProp "disabled"
          @$el.append '<div id="form"></div>'
          # @$el.append '<div id="form" class="wizard"></div>'
          @$el.find("section").show()

        
        propertyWizard.on "property:save", (property) =>
          
          # Add new property to collection
          @properties.add property
          
          # Reset form
          @$el.find("#new-property").removeProp "disabled"
          @$el.append '<div id="form"></div>'
          # @$el.append '<div id="form" class="wizard"></div>' 
          @$el.find("section").show()
