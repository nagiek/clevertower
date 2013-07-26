define [
  "jquery", 
  "underscore", 
  "backbone", 
  'models/Photo',
  "i18n!nls/common"
  'templates/photo/show',
], ($, _, Parse, Photo, i18nCommon) ->

  class PhotoView extends Parse.View
  
    #... is a list tag.
    tagName: "li"
    className: "span4"
    
    # The DOM events specific to an item.
    events:
      "click .photo-destroy": "kill"
  
    # The PhotoView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Photo and a PhotoView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      @listenTo @model, "change", @render
      @listenTo @model, "destroy", @clear
  
    # Re-render the contents of the photo item.
    render: ->
      @$el.html JST["src/js/templates/photo/show.jst"](_.merge(@model.toJSON(), i18nCommon: i18nCommon))
      @

    # Remove the item, destroy the model.
    kill: =>
      @model.destroy() if confirm(i18nCommon.actions.confirm)

    clear : =>
      @remove()
      @undelegateEvents()
      delete this