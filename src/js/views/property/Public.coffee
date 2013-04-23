define [
  "jquery"
  "underscore"
  "backbone"
  "collections/PhotoList"
  'models/Property'
  "views/photo/Public"
  "i18n!nls/property"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
], ($, _, Parse, PhotoList, Property, PhotoView, i18nProperty, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends Parse.View

    el: '#main'

    initialize: ->
      @photos = new PhotoList [], property: @model

      @photos.bind "add", @addOne
      @photos.bind "reset", @addAll

    render: ->
      vars =
        property: @model.toJSON()
        cover: @model.cover('span9')
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
      
      @$el.html JST["src/js/templates/property/public.jst"](vars)
      @$list = $("#photos")

      @photos.fetch()

      @

    addOne : (photo) =>
      view = new PhotoView(model: photo)
      @$list.append view.render().el
      
    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      @$list.html ""
      unless @photos.length is 0
        @photos.each @addOne
      else
        @$list.before '<p class="empty">' + i18nProperty.collection.empty.photos + '</p>'