define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/listing"
  "i18n!nls/common"
  'templates/listing/search'
  'jqueryui'
  "gmaps"
], ($, _, Parse, i18nListing, i18nCommon) ->

  class ListingSearchView extends Parse.View
  
    el: "#specific-controls"
    
    initialize : (attrs) ->

      @view = attrs.view
      @on "model:viewDetails", @clear
      @display = 'big'
      @min = 0
      @max = 6000

    events:
      'click #displays > button'        : 'changeDisplay'

    changeDisplay: (e) =>
      e.preventDefault()
      display = e.currentTarget.attributes["data-display"].value

      return if display is @display
      @view.$("#activities").removeClass(@display).addClass(display)

      @display = display

      _.each @view.listViews, (lv) -> lv.resize()

      # @view.trigger "view:refresh", @display
      # @$list.masonry 'reload'

    render: ->
      vars = 
        i18nListing: i18nListing
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/listing/search.jst"](vars)

      @$("#price-slider").slider
        values: [@min, @max]
        step: 10
        range: true 
        min: @min
        max: @max
        slide: (event, ui) -> 
          selector = if ui.value is ui.values[0] then "#slider-min" else "#slider-max"
          $(selector).html ui.value
        stop: (event, ui) => 
          @min = ui.values[0]
          @max = ui.values[1]
          Parse.App.activity.query.greaterThanOrEqualTo("rent", @min).lessThanOrEqualTo("rent", @max)
          Parse.User.current().activity.query.greaterThanOrEqualTo("rent", @min).lessThanOrEqualTo("rent", @max) if Parse.User.current()
          @view.redoSearch()
      @

    clear : => 
      @$("#price-slider").slider("destroy")
      @$el.empty()
      @stopListening()
      @undelegateEvents()
      delete Parse.App.activity.query._where.rent
      delete Parse.User.current().activity.query._where.rent if Parse.User.current()
      delete this

    # keep if model passes
    filter : (a) => 
      @min < a.get('rent') and a.get('rent') < @max