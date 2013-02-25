# Collection.js
# -------------
define ["jquery", "backbone", "models/Model"], ($, Backbone, Model) ->
  
  # Creates a new Backbone Collection class object
  
  # Tells the Backbone Collection that all of it's models will be of type Model (listed up top as a dependency)
  Collection = Backbone.Collection.extend(model: Model)
  
  # Returns the Model class
  Collection
