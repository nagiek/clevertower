define [
  "jquery"
  "underscore"
  "backbone"
  'collections/tenant/TenantList'
  'models/Tenant'
  'models/Profile'
  'views/helper/Alert'
  'views/tenant/Summary'
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/network/sub/tenants'
], ($, _, Parse, TenantList, Tenant, Profile, Alert, TenantView, i18nGroup, i18nCommon) ->

  class NetworkTenantsView extends Parse.View
  
    el: ".content"
    
    events:
      'submit form' : 'save'
    
    initialize: (attrs) ->
      
      _.bindAll this, 'addOne', 'addAll', 'render'
      
      @on "submit:success", (models) -> 
        @model.tenants.add models
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'
        @$('.emails-group input').val('')
      
      @on "submit:return", -> @$('button.save').removeProp "disabled"

      @on "submit:fail", (error) ->
        @$('.emails-group').addClass('error')
        new Alert event: 'model-save', fade: false, message: i18nCommon.errors[error.message], type: 'error'
      
      @model.prep('tenants')
      
      @model.tenants.on "add",   @addOne
      @model.tenants.on "reset", @addAll
      
      @render()
      
    # Re-render the contents of the Unit item.
    render: ->
      
      vars = _.merge(i18nGroup: i18nGroup, i18nCommon: i18nCommon)
      @$el.html JST["src/js/templates/network/sub/tenants.jst"](vars)
      
      @$list = @$('#tenants')

      if @model.tenants.length is 0 then @model.tenants.fetch() else @addAll()
      @
      
    addOne : (tenant) ->
      @$list.append (new TenantView(model: tenant)).render().el

    addAll : ->
      if @model.tenants.length is 0 then @$list.html "<li class='span'>#{i18nGroup.tenant.empty.index}</li>"
      else
        @$list.html ""
        @model.tenants.each @addOne
            
    save : (e) ->
      e.preventDefault()

      @$('button.save').prop "disabled", "disabled"
      @$('.error').removeClass('error')
      
      data = @$('form').serializeObject()

      # Validate tenants (assignment done in Cloud)
      userValid = unless Parse.User::validate(email: data.tenant.email) then true else false

      unless userValid
        @$('.emails-group').addClass('error')
        @trigger "submit:return"
        @trigger "submit:fail", {message: 'email_incorrect'}
      else
        attrs =
          emails: [ data.tenant.email ]
          networkId: @model.id
        Parse.Cloud.run "AddTenants", attrs,
        success: (modelObject) => 
          models = _.toArray modelObject
          @trigger "submit:return"
          @trigger "submit:success", models
        error: (error) => 
          @trigger "submit:return"
          @trigger "submit:fail", error