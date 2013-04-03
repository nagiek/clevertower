define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Unit'
  'models/Lease'
  'views/helper/Alert'
  "i18n!nls/lease"
  "i18n!nls/unit"
  "i18n!nls/common"
  'templates/unit/summary'
], ($, _, Parse, moment, Unit, Lease, Alert, i18nLease, i18nUnit, i18nCommon) ->

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
      @model.on "change:title", =>
        @$('.unit-link').html @model.get "title"
      
      @model.on "save:success", =>
        @render()
        
      @model.on "remove", =>
        @remove()
        @undelegateEvents()
        delete this
      
      @model.on "invalid", (unit, error) =>
        # Mark up form
        @$el.addClass('error')
        switch error.message
          when 'title_missing'
            @$('.title-group .control-group').addClass('error')

        msg = if error.code? i18nCommon.errors[error.message] else i18nUnit.errors[error.message]
        new Alert(event: 'unit-invalid', fade: false, message: msg, type: 'error')

    # Re-render the contents of the Unit item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        moment: moment
        objectId: if @model.id then @model.id else false
        propertyId: @model.get("property").id
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        isNew: @model.isNew()
      )
      if vars.activeLease = @model.get("activeLease") 
        end_date = @model.get("activeLease").get("end_date")
        vars.end_date = if @model.get("has_lease") and end_date then moment(end_date).format("MMM DD YYYY") else false
      else
        vars.activeLease = false
        
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
    