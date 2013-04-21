define [
  "jquery", 
  "underscore", 
  "backbone", 
  'models/Photo',
  "i18n!nls/common"
  'templates/photo/public',
], ($, _, Parse, Photo, i18nCommon) ->

  class PublicPhotoView extends Parse.View
  
    #... is a list tag.
    tagName: "li"
    className: "span3"
    
    initialize: ->
      _.bindAll this, "render"
  
    # Re-render the contents of the photo item.
    render: ->
      $(@el).html JST["src/js/templates/photo/public.jst"](url: @model.get("url"))
      @