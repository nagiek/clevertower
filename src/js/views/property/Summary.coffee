define [
  "jquery", 
  "underscore", 
  "backbone", 
  'models/Property',
  'templates/property/summary',
], ($, _, Parse, Property) ->

  class PropertySummaryView extends Parse.View
  
    #... is a list tag.
    tagName: "li"
    
    # The DOM events specific to an item.
    events:
      "click .toggle": "toggleDone"
      "dblclick label.property-content": "edit"
      "keypress .edit": "updateOnEnter"
      "blur .edit": "close"

  
    # The PropertyView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Property and a PropertyView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      _.bindAll this, "render", "close"
      @model.bind "change", @render

  
    # Re-render the contents of the property item.
    render: ->
      $(@el).html JST["src/js/templates/property/summary.jst"](@model.toJSON())
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