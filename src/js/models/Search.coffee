define [
  'underscore'
  'backbone'
  "moment"
], (_, Parse, moment) ->

  Search = Parse.Object.extend "Search",
  
    className: "Search"