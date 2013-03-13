define [
  "jquery", 
  "underscore", 
  "backbone", 
  'models/Property',
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/summary',
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertySummaryView extends Parse.View
  
    #... is a list tag.
    tagName: "li"
    
    # The DOM events specific to an item.
    events:
      "click .toggle"                   : "toggleDone"
      "dblclick label.property-content" : "edit"
      "keypress .edit"                  : "updateOnEnter"
      "blur .edit"                      : "close"

  
    # The PropertyView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Property and a PropertyView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      _.bindAll this, "render", "close"
      
      # Convert to collections.
      @model.set 
        cover        : @model.cover('profile')
        tasks        : '0'            # @model.tasks()
        incomes      : '0'            # @model.incomes().sum()
        expenses     : '0'            # @model.expenses().sum()
        vacant_units : '0'            # @model.units().vacant().length
        units        : '0'            # @model.units().length
      
      @model.bind "change", @render

  
    # Re-render the contents of the property item.
    render: ->
      
      $(@el).html JST["src/js/templates/property/summary.jst"](_.merge(@model.toJSON(),i18nProperty: i18nProperty, i18nCommon: i18nCommon))
      @input = @$(".edit")
      this

  
    # Toggle the `"done"` state of the model.
    toggleDone: ->
      @model.toggle()

  
    # Switch this view into `"editing"` mode, displaying the input field.
    edit: ->
      $(@el).addClass "editing"
      @input.focus()

  
    # Close the `"editing"` mode, saving changes to the property.
    close: ->
      @model.save content: @input.val()
      $(@el).removeClass "editing"

  
    # If you hit `enter`, we're through editing the item.
    updateOnEnter: (e) ->
      @close()  if e.keyCode is 13