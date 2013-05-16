define [
  "jquery"
  "underscore"
  "backbone"
  "collections/ActivityList"
  "views/activity/Summary"
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/user/home"
  'gmaps'
], ($, _, Parse, ActivityList, ActivityView, i18nUser, i18nProperty, i18nCommon) ->

  class UserHomeView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#main"
    
    initialize: (attrs) ->

      Parse.Dispatcher.on "user:logout", @clear

      # Get the property from what we've already loaded.
      if Parse.User.current().get("property") and if Parse.User.current().get("property").id is @model.get("property").id then @property = Parse.User.current().get("property")
      else if Parse.User.current().get("network") and if Parse.User.current().get("network").id is @model.get("network").id then @property = Parse.User.current().get("network").properties.get @model.get("property").id


    # Re-render the contents of the property item.
    render: =>
      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty

      @$el.html JST["src/js/templates/user/home.jst"](vars)

      @$list     = @$("#activity")
      @addAll()
      @
    
    addAll: (collection, filter) =>
      if Parse.User.current().activity.length > 0 then @$('li.empty').remove(); Parse.User.current().activity.each @addOne
      else @$list.html '<li class="empty">' + i18nUser.empty.activities.index + '</li>'

    addOne: (a) =>
      console.log @$list
      @$list.append new ActivityView(model: a, property: @property).render().el

    clear: (e) =>
      @undelegateEvents()
      delete this