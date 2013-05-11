define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/listing/highlight'
], ($, _, Parse, moment, i18nListing, i18nCommon) ->

  class ListingHighlightView extends Parse.View
  
    tagName: "li"
    className: "item"

    events:
      "click a" : "goToProperty"

    initialize : (attrs) ->
      @view = attrs.view
      @index = attrs.index
      @listenTo @view, "model:viewDetails", @clear

    # attributes: =>
    #   console.log @display


    goToProperty: (e) =>
      e.preventDefault()
      require ["views/property/Public"], (PublicPropertyView) => 
        p = @model.get("property")
        # Could assign a place from last search, but we don't know for sure.
        new PublicPropertyView(model: p).render()
        Parse.history.navigate p.publicUrl()
        @view.trigger "model:viewDetails"


    # Re-render the contents of the Unit item.
    render: =>
      vars = 
        title: @model.get("title")
        rent: @model.get("rent")
        locality: @model.get("locality")
        publicUrl: @model.get("property").publicUrl()
        profile: @model.get("property").cover('large')
        index: @index
        # createdAt: moment(@model.createdAt).fromNow()
        i18nCommon: i18nCommon
        i18nListing: i18nListing

      @$el.html JST["src/js/templates/listing/highlight.jst"](vars)
      $('#backdrops').append "<div id='backdrop-#{@index}' class='backdrop fade' style='background-image: url(/img/listings/#{@model.get("cover")});'></div>"

      @

    clear : => 
      @remove()
      @undelegateEvents()
      delete this