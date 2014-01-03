define [
  'underscore'
  'backbone'
], (_, Parse) ->

  Location = Parse.Object.extend "Location",
  # class Property extends Parse.Object
    
    className: "Location"

    url: -> "/outside" + @slug()

    slug: ->
      if @get("googleName")
        "/" + @get("googleName")
      else 
        hardCopy = Parse.App.locations.find((l) => l.id is @id)
        if hardCopy then hardCopy.get("googleName")