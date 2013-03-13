define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Unit'
  'models/Lease'
  "i18n!nls/lease"
  "i18n!nls/unit"
  "i18n!nls/common"
  'templates/unit/summary'
], ($, _, Parse, moment, Unit, Lease, i18nLease, i18nUnit, i18nCommon) ->

  class UnitSummaryView extends Parse.View
  
    #... is a table row.
    tagName: "tr"

    events:
      'blur input'        : 'update'
      'blur textarea'     : 'update'
      'blur select'       : 'updateS'
      'click .remove'     : 'remove'
      'click .delete'     : 'kill'
      
    initialize: () ->
      @$messages = $("#messages")
      
      @model.on "change:title", =>
        @$('.unit-link').html @model.get "title"
      
      @model.on "save:success", =>
        @render()
      
      @model.on "invalid", (unit, error) =>
        # Mark up form
        @$('.error').removeClass('error')
        @$el.addClass('error')
        switch error.message
          when 'title_missing'
            @$('.title-group .control-group').addClass('error')

        # Flash message
        @$messages
          .removeClass('alert-success')
          .addClass('alert-error')
          .show()
          .html(i18nUnit.errors[error.message])
          # .delay(6000)
          # .fadeOut()

    # Re-render the contents of the Unit item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        moment: moment
        propertyId: @model.get("property").id
        objectId: @model.get "objectId"
        isNew: @model.isNew()
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
      )
      $(@el).html JST["src/js/templates/unit/summary.jst"](vars)
      @

    update: (e) ->
      name = e.currentTarget.name
      value = e.currentTarget.value
      @model.set name, value
      e

    updateS: (e) ->
      name = e.currentTarget.name
      value = Number e.currentTarget.value
      @model.set name, value
      e

    kill : (e) ->
      e.preventDefault()
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        id = @model.get("property").id
        @model.destroy()
        @remove()
        @undelegateEvents()
        delete this
        Parse.history.navigate "/properties/#{id}"
    