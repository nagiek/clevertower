define [
  "jquery"
  "underscore"
  "backbone"
  'models/Profile'
  'templates/profile/inline'
], ($, _, Parse, Profile) ->

  class ApplicantSummaryView extends Parse.View
  
    tagName: "li"
  
    # Re-render the contents of the property item.
    render: ->
      vars = 
        objectId: @model.get("profile").id
        url: @model.get("profile").cover 'thumb'
        name: @model.get("profile").name()
        
      @$el.html JST["src/js/templates/profile/inline.jst"](vars)
      @
    