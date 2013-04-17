define [
  "jquery"
  "underscore"
  "backbone"
  "models/Profile"
  "i18n!nls/user"
  'templates/profile/show'
], ($, _, Parse, Profile, i18nUser) ->

  class ShowProfileView extends Parse.View
  
    el: "#main"
    
    initialize: (attrs) ->
      @current = attrs.current
    
    render: ->      
      vars = _.merge(
        @model.toJSON(),
        cover: @model.cover 'profile'
        name: @model.name()
        i18nUser: i18nUser
        current: @current
        create: moment(@model.createdAt).format("LLL")
      )
      _.defaults vars, Profile::defaults
      @$el.html JST["src/js/templates/profile/show.jst"](vars)
      @
      