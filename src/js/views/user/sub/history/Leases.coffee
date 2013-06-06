define [
  "jquery"
  "underscore"
  "backbone"
  "views/lease/own"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/user/sub/history/leases'
], ($, _, Parse, LeaseView, i18nUser, i18nCommon) ->

  # This actually grabs the tenants, not the leases.
  class UserLeasesView extends Parse.View
  
    el: "#leases"
    
    initialize: (attrs) ->

      @model = Parse.User.current().get("profile")

      @listenTo Parse.Dispatcher, "user:logout", @clear

      @model.prep('tenants')
      @listenTo @model.tenants, "reset", @addAll
    
    render: ->
      vars = 
        i18nUser: i18nUser
        i18nCommon: i18nCommon
      @$el.html JST["src/js/templates/user/sub/history/leases.jst"](vars)

      @$list = @$("ul#lease-list")

      if @model.tenants.length > 0 then @addAll() else @model.tenants.fetch()
      @

    clear: ->
      @remove()
      @undelegateEvents()
      delete this

    # Inquiries
    # ---------

    addOne : (l) =>
      @$list.append (new LeaseView(model: l)).render().el

    addAll : =>
      @$list.html ""
      unless @model.tenants.length is 0
        @model.tenants.each @addOne
      else @$list.html '<li class="empty">' + i18nUser.empty.leases + '</li>'
      