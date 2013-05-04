define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/user"
  "i18n!nls/common"
  "templates/user/home"
], ($, _, Parse, i18nUser, i18nCommon, inflection) ->

  class UserHomeView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: ".user-content"
    
    initialize: (attrs) ->

      _.bindAll this, 'render'

    # Re-render the contents of the property item.
    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nUser: i18nUser
      @$el.html JST["src/js/templates/user/home.jst"](vars)
      @
