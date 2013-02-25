# View.js
# -------
define ["jquery", "backbone", "models/Model", "text!templates/heading.html"], ($, Backbone, Model, template) ->
  View = Backbone.View.extend(
    
    # The DOM Element associated with this view
    el: ".example"
    
    # View constructor
    initialize: ->
      
      # Calls the view's render method
      @render()

    
    # View Event Handlers
    events: {}
    
    # Renders the view's template to the UI
    render: ->
      
      # Setting the view's template property using the Underscore template method
      @template = _.template(template, {})
      
      # Dynamically updates the UI with the view's template
      @$el.html @template
      
      # Maintains chainability
      this
  )
  
  # Returns the View class
  View
