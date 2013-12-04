define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  'models/Profile'
  "i18n!nls/common"
  "i18n!nls/group"
  'templates/profile/summary'
], ($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) ->

  class TenantSummaryView extends Parse.View
  
    tagName: "li"
    className: "col-sm-6 col-md-4"
    
    events:
      'click .delete' : 'kill'
    
    initialize : (attrs) ->
      
      @listenTo @model, "destroy", @clear
  
    # Re-render the contents of the property item.
    render: ->
      status = @model.get 'status'
      vars = _.merge @model.get("profile").toJSON(),
        i_status: i18nGroup.fields.status[status]
        status: status
        name: @model.get("profile").name()
        url: @model.get("profile").cover 'thumb'
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup

      @$el.html JST["src/js/templates/profile/summary.jst"](vars)
      @
    
    kill: ->
      if confirm(i18nCommon.actions.confirm)
        @model.destroy()

    clear: =>
      @remove()
      @undelegateEvents()
      delete this
      