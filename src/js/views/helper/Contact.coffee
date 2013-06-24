define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/common"
  "templates/helper/contact"
], ($, _, Parse, i18nCommon) ->

  class ContactView extends Parse.View
    
    tagName: 'tr'

    events:
      "click .select" : 'select'
    
    initialize: (attrs) ->

      @view = attrs.view
      @listenTo attrs.modal, "close", @clear

    render: ->
      @$el.html JST["src/js/templates/helper/contact.jst"](name: @model.get("name"), email: @model.get("email"), i18nCommon: i18nCommon)
      @

    select: (e) =>
      # e.preventDefault()
      @$(".select").html(i18nCommon.adjectives.selected).prop "disabled", true
      @view.$("#tenant-list").val(@view.$("#tenant-list").val()+@model.get("email")+', ')

    clear: =>
      @remove()
      @undelegateEvents()
      delete this