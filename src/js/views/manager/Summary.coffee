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
      'click .accept' : 'accept'
      'click .delete' : 'kill'
    
    initialize : (attrs) ->
      @listenTo @model, "destroy", @clear
  
    # Re-render the contents of the property item.
    render: ->
      status = @model.get 'status'
      current_user = @model.get("profile").id is Parse.User.current().get("profile").id
      vars = _.merge @model.get("profile").toJSON(),
        i_status: i18nGroup.fields.status[status]
        status: status
        mgr: Parse.User.current().get("network").mgr
        admin: @model.get 'admin'
        current_user: current_user
        current_user_leave: if @model.collection.length is 1 and Parse.User.current().get("network").mgr then i18nGroup.manager.delete_network else i18nCommon.actions.leave
        url: @model.get("profile").cover('thumb')
        i18nCommon: i18nCommon
        
      vars.name = @model.get("profile").get("email") unless vars.name
      @$el.html JST["src/js/templates/profile/tablerow.jst"](vars)
      @
    
    kill: =>
      if confirm(i18nCommon.actions.confirm)
        # Remove the manager
        @model.destroy()

        # Take additional actions if we are refering to ourselves.
        if @model.get("profile").id is Parse.User.current().get("profile").id

          # Delete the network if we are the last ones.
          if @model.collection.length is 1 and Parse.User.current().get("network").mgr 
            Parse.User.current().get("network").destroy()

          Parse.User.current().save("network", null)

          # Go to the home
          hostArray = location.host.split(".")
          hostArray.shift()
          home = hostArray.join(".")

          domain = "#{location.protocol}//#{home}"
          setTimeout window.location.replace domain, 1000

    accept: ->
      @model.save(newStatus:"current")
      @render()

    clear: =>
      @remove()
      @undelegateEvents()
      delete this