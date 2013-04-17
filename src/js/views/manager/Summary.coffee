define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  'models/Profile'
  "i18n!nls/common"
  "i18n!nls/group"
  'templates/profile/tablerow'
], ($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) ->

  class ManagerSummaryView extends Parse.View
  
    tagName: "tr"
    
    events:
      'click .delete' : 'kill'
    
    initialize : (attrs) ->
      _.bindAll 'this', 'render'
      
      @model.on "destroy", =>
        @remove()
        @undelegateEvents()
        delete this
  
    # Re-render the contents of the property item.
    render: ->
      status = @model.get 'status'
      current_user = @model.get("profile").id is Parse.User.current().profile.id
      vars = _.merge @model.get("profile").toJSON(),
        i_status: i18nGroup.fields.status[status]
        status: status
        admin: @model.get 'admin'
        current_user: current_user
        current_user_leave: if @model.collection.length > 1 then i18nCommon.actions.leave else i18nGroup.manager.delete_network
        url: @model.get("profile").cover('thumb')
        i18nCommon: i18nCommon
        
      vars.name = @model.get("profile").get("email") unless vars.name
      @$el.html JST["src/js/templates/profile/tablerow.jst"](vars)
      @
    
    kill: ->
      if confirm(i18nCommon.actions.confirm)
        @model.destroy()