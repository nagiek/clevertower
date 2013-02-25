# Filename: router.js
define [
  "jquery", 
  "underscore", 
  "parse",
], ($, _, Parse) ->

  class AppRouter extends Parse.Router
    routes:
      all: "all"
      active: "active"
      completed: "completed"

    initialize: (options) ->

    all: ->
      state.set filter: "all"

    active: ->
      state.set filter: "active"

    completed: ->
      state.set filter: "completed"
  
  initialize = ->
  
    new AppRouter;
    Parse.history.start();
  
  initialize: initialize
