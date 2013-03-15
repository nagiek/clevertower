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
  "templates/property/menu"
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/other"
  "templates/property/menu/actions"
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
      
      @$list = @$el.find("ul#view-id-my_properties")
      
      # Create our collection of Properties
      @properties = new PropertyList
      
      # Setup the query for the collection to look for properties from the current user
      @properties.query = new Parse.Query(Property)
      @properties.query.equalTo "user", Parse.User.current()
      @properties.bind "add", @addOne
      @properties.bind "reset", @addAll
      @properties.bind "all", @render
    
      # Fetch all the property items for this user
      @properties.fetch(
        success: (collection, resp, options) ->          
          query = new Parse.Query("Unit");
          query.containedIn "property", collection.models
          # groupBy not supported yet.
          # query.groupBy "property"
          query.count(
            success: (number) ->
              collection.each (property) -> 
                property.unitsLength = number
          )
      )
      #
      
    render: =>
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
      @$('p.empty').remove() if @$('p.empty') # Clear "empty" text
      view = new PropertyView(model: property)
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless @properties.length is 0
        @properties.each @addOne
        @$list.children(':even').children().addClass 'views-row-even'
        @$list.children(':odd').children().addClass  'views-row-odd'
      else
        @$list.html '<p class="empty">' + i18nProperty.collection.empty + '</p>'

    # showProperty : (id) ->
    #   Parse.history.navigate "/properties/#{id}"
    #   require ["views/property/Show"], (PropertyView) =>
    #     propertyView = new PropertyView

    newProperty : ->

      require ["views/property/new/Wizard"], (PropertyWizard) =>
        @$el.find("#new-property").prop disabled: "disabled"
        @$el.find("section").hide()
        propertyWizard = new PropertyWizard
        Parse.history.navigate "/properties/new"

        propertyWizard.on "wizard:cancel", =>
          
          # Reset form
          @$el.find("#new-property").removeProp "disabled"
          @$el.find("section").show()

        
        propertyWizard.on "property:save", (property) =>
          
          # Add new property to collection
          @properties.add property
          
          # Reset form
          @$el.find("#new-property").removeProp "disabled"
          @$el.find("section").show()
