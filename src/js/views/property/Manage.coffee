define [
  "jquery"
  "underscore"
  "backbone"
  'collections/property/PropertyList',
  "models/Network"
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
], ($, _, Parse, PropertyList, Network, Property, SummaryPropertyView, i18nProperty, i18nCommon) ->

  class ManagePropertiesView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    events:
      'click #new-property' : "newProperty"
    
    initialize : ->
      
      _.bindAll this, 'newProperty'
      
      if !Parse.User.current().properties then Parse.User.current().properties = new PropertyList
      
      # Setup the query for the collection to look for properties from the current user
      Parse.User.current().properties.on "add", @addOne
      Parse.User.current().properties.on "reset", @addAll
      
      # custom listeners for seeing properties.
      Parse.User.current().properties.on "show", => @$propertyList.hide()
      Parse.User.current().properties.on "close", => @$propertyList.show()

    render: =>
      network = Parse.User.current().get("network")
      _.defaults network.attributes, Network::defaults
      vars = _.merge network.toJSON(),
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      # vars.title = network.get("name") unless vars.title
      @$el.html JST["src/js/templates/property/manage.jst"](vars)
      
      
      @$propertyList = @$("#network-properties")
      @$managerList = @$("#network-managers")
      
      # Fetch all the property items for the network
      if Parse.User.current().properties.length is 0
        Parse.User.current().properties.fetch
          success: (collection, resp, options) ->          
            query = new Parse.Query("Unit");
            query.containedIn "property", collection.models
            # TODO: groupBy not supported yet.
            # query.groupBy "property"
            query.count
              success: (number) ->
                collection.each (property) -> 
                  property.unitsLength = number
      else
        @addAll()

    
    # Add a single property item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (property) =>
      @$('p.empty').remove() if @$('p.empty') # Clear "empty" text
      view = new SummaryPropertyView model: property
      @$propertyList.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$propertyList.html ""
      unless Parse.User.current().properties.length is 0
        Parse.User.current().properties.each @addOne
        @$propertyList.children(':even').children().addClass 'views-row-even'
        @$propertyList.children(':odd').children().addClass  'views-row-odd'
      else
        @$propertyList.html '<p class="empty">' + i18nProperty.collection.empty.properties + '</p>'

    # showProperty : (id) ->
    #   Parse.history.navigate "/properties/#{id}"
    #   require ["views/property/Show"], (PropertyView) =>
    #     propertyView = new PropertyView

    newProperty : ->

      require ["views/property/new/Wizard"], (PropertyWizard) =>
        @$("#new-property").prop disabled: "disabled"
        @$("section").hide()
        propertyWizard = (new PropertyWizard).render()
        Parse.history.navigate "/properties/new"

        propertyWizard.on "wizard:cancel", =>
          
          # Reset form
          @$("#new-property").removeProp "disabled"
          @$("section").show()

        
        propertyWizard.on "property:save", (property) =>
          
          # Add new property to collection
          Parse.User.current().properties.add property
          
          # Reset form
          @$("#new-property").removeProp "disabled"
          @$("section").show()
