define [
  "jquery"
  "underscore"
  "backbone"
  "views/listing/Featured"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/home/anon"
], ($, _, Parse, FeaturedListingView, i18nProperty, i18nCommon) ->

  class HomeAnonView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"

    events:
      "mouseover #featured-listings-wrapper" : "showControls"
      "mouseout #featured-listings-wrapper" : "hideControls"
      'submit form': 'doNothing'

    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:loginEnd", ->

      # Reload the current path. 
      # Don't use navigate, as it will fail.
      # The route functions themselves are responsible for altering content.
      Parse.history.loadUrl location.pathname

    # typeahead widget takes care of navigation.
    doNothing : (e) -> e.preventDefault()

    # Re-render the contents of the property item.
    render: =>

      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      @$el.html JST["src/js/templates/home/anon.jst"](vars)

      @$('.search-query').on "typeahead:selected", Parse.App.search.googleSearch
      @$('.search-query').typeahead Parse.App.search.vars

      @$list = @$("#featured-listings")
      @$listWrapper = @$("#featured-listings-wrapper")

      if Parse.App.featuredListings.length is 0 then Parse.App.featuredListings.fetch success: @addAll else @addAll()

      @

    addOne: (l, i) =>
      view = new FeaturedListingView
        model: l
        view: @
        index: i
      @$list.append view.render().el

    # Add all items in the Properties collection at once. We know it will be full by this point.
    addAll: (collection, filter) =>
      Parse.App.featuredListings.each @addOne
      @$list.find('> :first-child').addClass 'active'
      @showCaption()

      setTimeout =>
        @$listWrapper.carousel interval: 8000
        @$listWrapper.on 'slid', @showCaption
        @$listWrapper.on 'slide', => 
          @$('h1').removeClass('inverse')
          @$('#caption.in').removeClass('in')
          @$("#backdrops > .backdrop.in").removeClass 'in'
      , 3000

    showCaption : =>
      slide = @$list.find('> .active > a')
      setTimeout =>
        @$('#title').html slide.data('title')
        @$('#locality').html slide.data('locality')
        @$('#rent').html "$" + slide.data('rent')
        @$('h1').addClass('inverse')
        @$('#caption').addClass('in')
        @$("#backdrop-#{slide.data('index')}").addClass 'in'
      , 3000 

    showControls: => @$('.carousel-control').addClass 'half-in'
    hideControls: => @$('.carousel-control').removeClass 'half-in'

    clear: =>
      @stopListening()
      @undelegateEvents()
      delete this