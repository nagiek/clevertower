define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  'models/Profile'
  "i18n!nls/common"
  "i18n!nls/tenant"
  'templates/profile/summary'
], ($, _, Parse, Lease, Profile, i18nCommon, i18nTenant) ->

  class TenantSummaryView extends Parse.View
  
    tagName: "li"
    className: "span"
    
    events:
      'click .delete' : 'kill'
    
    initialize : (attrs) ->
      _.bindAll 'this', 'render'
      @profile = @model.get("profile")
      
      @model.on "destroy", =>
        @remove()
        @undeletegateEvents()
        delete this
  
    # Re-render the contents of the property item.
    render: ->
      status = @model.get 'status'
      vars = _.merge @profile.toJSON(),
        i_status: i18nTenant.fields.status[status]
        status: status
        url: @profile.cover 'thumb'
        i18nCommon: i18nCommon
        
      vars.name = @profile.get("email") unless vars.name
      @$el.html JST["src/js/templates/profile/summary.jst"](vars)
      @
    
    kill: ->
      if confirm(i18nCommon.actions.confirm)
        @model.destroy()