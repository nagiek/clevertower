define [
  "jquery"
  "underscore"
  "backbone"
  "models/Post"
  "views/activity/Summary"
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/user/home"
  'gmaps'
], ($, _, Parse, Post, ActivityView, i18nUser, i18nProperty, i18nCommon) ->

  class NewPostView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#user-container"

    events:
      "submit form"       : "post"
      "focus #post-title" : "showPostOptions"
      "click #show-body"  : "toggleBodyView"

    
    initialize: (attrs) ->

      Parse.Dispatcher.on "user:logout", @clear


    render: =>

      rand = Math.floor Math.random() * i18nUser.form.share.length
      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
        share_placeholder: i18nUser.form.share[rand]

      @$el.html JST["src/js/templates/user/home.jst"](vars)
      @$list = $("#activity")

    showPostOptions : (e) => @$('#post-options').removeClass 'hide'
    # Always show once you click
    # hidePostOptions : (e) => @$('#post-options').addClass 'hide'
    toggleBodyView : (e) => if e.currentTarget.checked then @$('.body-group').removeClass 'hide' else @$('.body-group').addClass 'hide'


    post : (e) ->
      e.preventDefault() if e

      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')

      post = new Post(data.post)

      post.save attrs,
        success: (model) => @addOne model
        error: (model, error) => 

    clear: (e) =>
      @el.html ""
      @stopListening()
      @undelegateEvents()
      delete this
