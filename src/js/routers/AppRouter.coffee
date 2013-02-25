# Filename: router.js
define [
  "jquery", 
  "backbone",
  "views/app/AppView"
], ($, Parse, AppView) ->

  class AppRouter extends Parse.Router
    routes:
      ""        : "index"

    initialize: (options) ->
      Parse.history.start();
  
    index: ->
      new AppView()