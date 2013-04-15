define [
  "jquery"
  "underscore"
  "backbone"
  'collections/manager/ManagerList'
  'models/Manager'
  'models/Profile'
  'views/manager/Summary'
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/network/managers'
], ($, _, Parse, ManagerList, Manager, Profile, ManagerView, i18nGroup, i18nCommon) ->

  class NetworkManagersView extends Parse.View
  
    el: ".content"
    
    events:
      'submit form' : 'save'
    
    initialize: (attrs) ->
      
      _.bindAll this, 'addOne', 'addAll', 'render'
      
      @model.prep('managers')
      
      @model.managers.on "add",   @addOne
      @model.managers.on "reset", @addAll
      
    # Re-render the contents of the Unit item.
    render: ->
      
      vars = _.merge(i18nGroup: i18nGroup, i18nCommon: i18nCommon)
      @$el.html JST["src/js/templates/network/managers.jst"](vars)
      
      @$list = @$('ul#managers')

      if @model.managers.length is 0 
        @model.managers.fetch
          success: (collection, response, options) =>
            if collection.length is 0 then @$("td.empty").text(i18nGroup.manager.empty).show()
      else @addAll()
      @
      
    addOne : (manager) ->
      @$("td.empty").hide()
      @$list.append (new ManagerView(model: manager)).render().el

    addAll : ->
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
        @model.trigger "invalid", {message: 'email_incorrect'}
      else
        @model.save attrs,
        success: (model) => 
          @trigger "save:success", model, this
        error: (model, error) => 
          @model.trigger "invalid", error