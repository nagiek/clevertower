define [
  "jquery"
  "underscore"
  "backbone"
  'collections/ManagerList'
  'models/Manager'
  'models/Profile'
  'views/helper/Alert'
  'views/manager/Summary'
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/network/sub/managers'
], ($, _, Parse, ManagerList, Manager, Profile, Alert, ManagerView, i18nGroup, i18nCommon) ->

  class NetworkManagersView extends Parse.View
    
    events:
      'submit form' : 'save'
    
    initialize: (attrs) ->
      
      @on "submit:success", (models) -> 
        @model.managers.add models
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        @$('.emails-group input').val('')
      
      @on "submit:return", -> @$('button.save').removeProp "disabled"

      @on "submit:fail", (error) ->
        @$('.emails-group').addClass('error')
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors[error.message], type: 'error'
      
      @model.prep('managers')
      
      @listenTo @model.managers, "add",   @addOne
      @listenTo @model.managers, "reset", @addAll
      
      @render()
      
    # Re-render the contents of the Unit item.
    render: =>
      
      vars = _.merge(i18nGroup: i18nGroup, i18nCommon: i18nCommon)
      @$el.html JST["src/js/templates/network/sub/managers.jst"](vars)
      
      @$list = @$('table#managers tbody')

      if @model.managers.length is 0 then @model.managers.fetch() else @addAll()
      @
      
    addOne : (manager) =>
      @$list.append (new ManagerView(model: manager)).render().el

    addAll : =>
      @$list.html ''
      @model.managers.each @addOne
            
    save : (e) ->
      e.preventDefault()

      @$('button.save').prop "disabled", "disabled"
      @$('.error').removeClass('error')
      
      data = @$('form').serializeObject()

      # Validate tenants (assignment done in Cloud)
      userValid = unless Parse.User::validate(email: data.manager.email) then true else false

      unless userValid
        @$('.emails-group').addClass('error')
        @trigger "submit:return"
        @trigger "submit:fail", {message: 'email_incorrect'}
      else
        attrs =
          emails: [ data.manager.email ]
          networkId: @model.id
        Parse.Cloud.run "AddManagers", attrs,
        success: (modelObject) => 
          models = _.toArray modelObject
          @trigger "submit:return"
          @trigger "submit:success", models
        error: (error) => 
          @trigger "submit:return"
          @trigger "submit:fail", error