define [
  "jquery"
  "underscore"
  "backbone"
  'collections/PropertyList',
  "models/Network"
  "models/Property"
  "views/property/summary"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/network/sub/properties"
  "templates/property/menu"
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, PropertyList, Network, Property, SummaryPropertyView, i18nProperty, i18nCommon) ->

  class ManagePropertiesView extends Parse.View
    
    # events:
    #   'click #new-property-link' : "newProperty"
    
    initialize : (attrs) ->
      
      # Setup the query for the collection to look for properties from the current user
      @listenTo Parse.User.current().get("network").properties, "add", @addOne
      @listenTo Parse.User.current().get("network").properties, "reset", @addAll
            
      @render()

    render: =>
      network = Parse.User.current().get("network")
      _.defaults network.attributes, Network::defaults
      vars = _.merge network.toJSON(),
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      # vars.title = network.get("name") unless vars.title
      @$el.html JST["src/js/templates/network/sub/properties.jst"](vars)
      
      @$propertyList = @$("#network-properties")
      @$managerList = @$("#network-managers")
      
      # Fetch all the property items for the network
      # if Parse.User.current().get("network").properties.length is 0
      #   Parse.User.current().get("network").properties.fetch()
      #     # success: (collection, resp, options) ->          
      #     #   query = new Parse.Query("Unit");
      #     #   query.containedIn "property", collection.models
      #     #   # TODO: groupBy not supported yet.
      #     #   # query.groupBy "property"
      #     #   query.count
      #     #     success: (number) ->
      #     #       collection.each (property) -> 
      #     #         property.unitsLength = number
      # else
      @addAll()
      @

    
    # Add a single property item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (property) =>
      @$('p.empty').remove() if @$('p.empty') # Clear "empty" text
      view = new SummaryPropertyView model: property
      @$propertyList.append view.render().el

    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$propertyList.html ""
      unless Parse.User.current().get("network").properties.length is 0
        Parse.User.current().get("network").properties.each @addOne
        @$propertyList.children(':even').children().addClass 'views-row-even'
        @$propertyList.children(':odd').children().addClass  'views-row-odd'
      else
        @$propertyList.html '<p class="empty">' + i18nProperty.collection.empty.properties + '</p>'

    # showProperty : (id) ->
    #   Parse.history.navigate "/properties/#{id}"
    #   require ["views/property/Show"], (PropertyView) =>
    #     propertyView = new PropertyView

    # newProperty : =>

    #   require ["views/property/new/Wizard"], (PropertyWizard) =>
    #     @$("#new-property-link").prop disabled: "disabled"
    #     # $("#main").addClass 'hide'
    #     $("#main > .container > .section").addClass 'hide'
    #     propertyWizard = new PropertyWizard
    #     propertyWizard.setElement "#full-modal"
    #     propertyWizard.render()
    #     Parse.history.navigate "/properties/new"
    #     $("#main > .container > #full-modal").removeClass 'hide'
        

    #     @listenTo propertyWizard, "wizard:cancel", =>
          
    #       # Reset form
    #       @$("#new-property-link").removeProp "disabled"
    #       $("#main > .container > #full-modal").addClass 'hide'
    #       $("#main > .container > .section").removeClass 'hide'
    #       Parse.history.navigate '/'
        
    #     @listenTo propertyWizard, "property:save", (property) =>
          
    #       # Add new property to collection
    #       Parse.User.current().get("network").properties.add property
          
    #       # Reset form
    #       @$("#new-property-link").removeProp "disabled"
    #       $("#main > .container > #full-modal").addClass 'hide'
    #       $("#main > .container > .section").removeClass 'hide'
    #       Parse.history.navigate '/'
