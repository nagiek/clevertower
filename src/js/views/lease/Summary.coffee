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
  'templates/lease/summary'
], ($, _, Parse, moment, Unit, Lease, Alert, i18nLease, i18nUnit, i18nCommon) ->

  class LeaseSummaryView extends Parse.View
  
    #... is a table row.
    tagName: "tr"

    events:
      'blur input'        : 'update'
      'blur textarea'     : 'update'
      'blur select'       : 'updateS'
      'click .remove'     : 'remove'
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->
      
      @onUnit = if attrs.onUnit then true else false
      @link_text = if @onUnit then i18nCommon.nouns.link else i18nCommon.classes.lease
          
      @model.on "save:success", =>
        @render()
        
      @model.on "destroy", =>
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
      
      modelVars = @model.toJSON()
      # Parse turns dates into an object, which we must override.
      modelVars.start_date = moment(@model.get "start_date").format("LL")
      modelVars.end_date = moment(@model.get "end_date").format("LL")
      
      vars = _.merge(
        modelVars,
        link_text: @link_text
        onUnit: @onUnit
        propertyId: @model.get("property").id
        unitId: @model.get("unit").id
        title: @model.get("unit").get("title")
        moment: moment
        propertyId: @model.get("property").id
        objectId: @model.get "objectId"
        isNew: @model.isNew()
        i18nCommon: i18nCommon
        i18nUnit: i18nUnit
        i18nLease: i18nLease
      )
      $(@el).html JST["src/js/templates/lease/summary.jst"](vars)
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
