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
      'click .remove'     : 'kill'
      'click .delete'     : 'delete'
      "keypress .title"   : "newOnEnter"
      
    initialize: () ->
      @listenTo @model, "change:title", =>
        @$('.unit-link').html @model.get "title"
      
      @listenTo @model.collection, "save:success", @render
      
      @listenTo @model, "invalid", (error) =>
        # Mark up form
        @$el.addClass('error')
        switch error.message
          when 'title_missing'
            @$('.title-group .control-group').addClass('error')

      @listenTo @model, "destroy", =>
        @remove()
        @undelegateEvents()
        delete this

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
        
      @$el.html JST["src/js/templates/unit/summary.jst"](vars)
      @$('[rel=tooltip]').tooltip()
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
      @model.destroy()

    delete : (e) ->
      e.preventDefault()
      if confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)
        id = @model.get("property").id
        @model.destroy()
        Parse.history.navigate "/properties/#{id}"
    
    # If you hit return in the main input field, save and create new
    newOnEnter: (e) =>
      return  unless e.keyCode is 13
      @update(e)
      @model.collection.prepopulate()