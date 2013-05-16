define [
  "jquery"
  "underscore"
  "backbone"
  'models/Unit'
  "i18n!nls/Unit"
  "i18n!nls/common"
  'templates/unit/new'
  'templates/unit/edit'
  'templates/unit/status'
], ($, _, Parse, Unit, i18nUnit, i18nCommon) ->

  class UnitEditView extends Parse.View
  
    #... is a table row.
    tagName: "tr"
    
    events:
      'blur input'    : 'update'
      'blur textarea' : 'update'
      'blur select'   : 'update'
      'click .remove' : 'remove'
      'click .delete' : 'kill'
  
    # The UnitView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a Unit and a UnitView in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      # @model.on "save", @render

    # Re-render the contents of the Unit item.
    render: =>
      template = if @model.isNew() then "src/js/templates/unit/new.jst" else "src/js/templates/unit/edit.jst"      
      $(@el).html JST[template](_.merge(@model.toJSON(), propertyId: @model.get("property").id, i18nUnit: i18nUnit, i18nCommon: i18nCommon))
      @
      
    update: (e) ->
      name = e.currentTarget.name
      value = e.currentTarget.value
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