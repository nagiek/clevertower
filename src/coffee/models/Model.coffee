# Model.js
# --------
define ["jquery", "backbone"], ($, Backbone) ->
  
  # Creates a new Backbone Model class object
  Model = Backbone.Object.extend("Model"
    
    # Model Constructor
    initialize: ->

    
    # Default values for all of the Model attributes
    defaults: {}
    
    # Gets called automatically by Backbone when the set and/or save methods are called (Add your own logic)
    validate: (attrs) ->
  )
  
  # Returns the Model class
  Model
