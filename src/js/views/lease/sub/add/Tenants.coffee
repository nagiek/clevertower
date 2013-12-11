define [
  "jquery"
  "underscore"
  "backbone"
  "collections/UnitList"
  "models/Property"
  "models/Unit"
  "models/Lease"
  "views/helper/Alert"
  "views/tenant/New"
  "i18n!nls/lease"
  "i18n!nls/common"
  "templates/lease/sub/add/tenants"
], ($, _, Parse, UnitList, Property, Unit, Lease, Alert, NewTenantsView, i18nLease, i18nCommon) ->

  class AddTenantsToLeaseView extends Parse.View

    el: '.content'
    
    events:
      'submit .tenants-form'          : 'save'
    
    initialize : (attrs) ->
      
      @baseUrl = attrs.baseUrl
      @forNetwork = attrs.forNetwork
      @view = attrs.view

      @model.prep "tenants"
      
      @on 'submit:return', => @$('button.save').button "reset"
      
      @on 'submit:error', (error) =>
        console.log error
        @$('.emails-group').addClass('has-error') 
        new Alert event: 'model-save', fade: false, message: i18nLease.errors[error.message], type: 'danger'
      
      @on "submit:success", (model) =>
        new Parse.Query("Tenant").equalTo("lease", @model).include("profile").find()
        .then (objs) =>
          @model.tenants.add objs

          Parse.history.navigate @baseUrl, true
          @clear()

    save : (e) =>
      e.preventDefault()
      
      @$('button.save').button "loading"
      @$('.has-error').removeClass('has-error')
      data = @$('form').serializeObject()
      
      attrs = 
        objectId: @model.id
        className: "Lease"
      
      # Validate tenants (assignment done in Cloud)
      userValid = true
      if data.emails and data.emails isnt ''
        # Create a temporary array to temporarily hold accounts unvalidated users.
        attrs.emails = []
        _.each data.emails.split(","), (email) =>
          email = $.trim(email)
          # validate is a backwards function.
          userValid = unless Parse.User::validate(email: email) then true else false
          attrs.emails.push email if userValid

      
      unless userValid
        @trigger "submit:return"
        @trigger "submit:error", {message: 'tenants_incorrect'}
      else
        Parse.Cloud.run "AddTenants", attrs,
        success: (model) =>
          @trigger "submit:return"
          @trigger "submit:success", model
        error: (model, error) =>
          @trigger "submit:return"
          @trigger "submit:error", message: 'tenants_incorrect'

    render: ->
      vars =
        baseUrl: @baseUrl
        cancelPath: @baseUrl
        i18nCommon: i18nCommon
        i18nLease: i18nLease
      
      @$el.html JST["src/js/templates/lease/sub/add/tenants.jst"](vars)
      @

    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this