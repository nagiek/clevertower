define [
  "jquery"
  "underscore"
  "backbone"
  'models/Profile'
  'templates/profile/inline'
], ($, _, Parse, Profile) ->

  class ApplicantSummaryView extends Parse.View
  
    tagName: "li"
    
    initialize : (attrs) ->
      _.bindAll 'this', 'render'
      @profile = @model.get("profile")
  
    # Re-render the contents of the property item.
    render: ->
      vars = 
        objectId: @profile.id
        url: @profile.cover 'thumb'
        name: @profile.name()
        
      @$el.html JST["src/js/templates/profile/inline.jst"](vars)
      @
    