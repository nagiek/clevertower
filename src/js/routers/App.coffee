define [
  "jquery", 
  "backbone",
  "views/app/Main"
], ($, Parse, AppView) ->

  class AppRouter extends Parse.Router
    routes:
      ""         : "index"
      "*actions" : "index"

    initialize: (options) ->
      Parse.history.start pushState: true
        
    index: ->
      new AppView()