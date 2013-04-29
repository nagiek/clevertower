define [
  "jquery"
  "underscore"
  "backbone"
  "models/Profile"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/profile/show'
], ($, _, Parse, Profile, i18nUser, i18nCommon) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"

    events:
      'click .nav a' : 'showTab'
    
    initialize: (attrs) ->
      @current = attrs.current
    
    render: ->      
      vars = _.merge @model.toJSON(),
        cover: @model.cover 'profile'
        name: @model.name()
        i18nUser: i18nUser
        i18nCommon: i18nCommon
        current: @current
        createdAt: moment(@model.createdAt).format("L")
      
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/profile/show.jst"](vars)
      @
      
    showTab : (e) ->
      e.preventDefault()
      $(e.currentTarget).tab('show')