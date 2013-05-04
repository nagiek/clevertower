define [
  "jquery"
  "underscore"
  "backbone"
  "views/listing/index"
  "views/user/home"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/home/anon"
], ($, _, Parse, ListingIndexView, UserHomeView, i18nProperty, i18nCommon) ->

  class HomeAnonView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: ".user-content"
    
    initialize: (attrs) ->

      _.bindAll this, 'render'


    # Re-render the contents of the property item.
    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
      @$el.html JST["src/js/templates/home/anon.jst"](vars)

      @
