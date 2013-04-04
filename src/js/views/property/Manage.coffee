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
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, PropertyList, Property, SummaryPropertyView, i18nProperty, i18nCommon) ->

  class ManagePropertiesView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    events:
      'click #new-property' : "newProperty"
    
    initialize : ->
      @$el.html JST["src/js/templates/property/manage.jst"](i18nCommon: i18nCommon, i18nProperty: i18nProperty)
      
      _.bindAll this, 'newProperty'
      
      @$list = @$("ul#view-id-my_properties")
      
      # Setup the query for the collection to look for properties from the current user
      @collection.on "add", @addOne
      @collection.on "reset", @addAll
      @collection.on "all", @render
      
      # custom listeners for seeing properties.
      @collection.on "show", => @$list.hide()
      @collection.on "close", => @$list.show()
    
      # Fetch all the property items for this user
      @collection.fetch
        success: (collection, resp, options) ->          
          query = new Parse.Query("Unit");
          query.containedIn "property", collection.models
          # TODO: groupBy not supported yet.
          # query.groupBy "property"
          query.count
            success: (number) ->
              collection.each (property) -> 
                property.unitsLength = number

    render: =>
      # done = @collection.done().length
      # remaining = @collection.remaining().length
      # @$("#property-stats").html @statsTemplate(
      #   total: @collection.length
      #   done: done
      #   remaining: remaining
      # )
      # @delegateEvents()
      # @allCheckbox.checked = not remaining
    
    # Add a single property item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (property) =>
      @$('p.empty').remove() if @$('p.empty') # Clear "empty" text
      view = new SummaryPropertyView(model: property)
      @$list.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless @collection.length is 0
        @collection.each @addOne
        @$list.children(':even').children().addClass 'views-row-even'
        @$list.children(':odd').children().addClass  'views-row-odd'
      else
        @$list.html '<p class="empty">' + i18nProperty.collection.empty.properties + '</p>'

    # showProperty : (id) ->
    #   Parse.history.navigate "/properties/#{id}"
    #   require ["views/property/Show"], (PropertyView) =>
    #     propertyView = new PropertyView

    newProperty : ->

      require ["views/property/new/Wizard"], (PropertyWizard) =>
        @$("#new-property").prop disabled: "disabled"
        @$("section").hide()
        propertyWizard = new PropertyWizard
        Parse.history.navigate "/properties/new"

        propertyWizard.on "wizard:cancel", =>
          
          # Reset form
          @$("#new-property").removeProp "disabled"
          @$("section").show()

        
        propertyWizard.on "property:save", (property) =>
          
          # Add new property to collection
          @collection.add property
          
          # Reset form
          @$("#new-property").removeProp "disabled"
          @$("section").show()
