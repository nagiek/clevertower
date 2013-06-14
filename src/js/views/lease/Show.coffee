define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'collections/TenantList'
  'models/Unit'
  'models/Lease'
  'models/Tenant'
  'views/tenant/Summary'
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
  'templates/lease/show'
], ($, _, Parse, moment, TenantList, Unit, Lease, Tenant, TenantView, i18nUnit, i18nLease, i18nCommon) ->
  
  class ShowLeaseView extends Parse.View
    
    el: ".content"
    
    initialize: (attrs) =>
      @property = attrs.property
      @baseUrl = attrs.baseUrl
      
      @model.prep('tenants')
      
      @listenTo @model.tenants, "add",   @addOne
      @listenTo @model.tenants, "reset", @addAll
      
    # Re-render the contents of the Unit item.
    render: ->    

      isMgr = Parse.User.current().get("network") and Parse.User.current().get("network").id is @model.get("network").id 

      vars = _.merge @model.toJSON(), 
        # References
        unitId: @model.get("unit").id
        title: @model.get("unit").get("title")
        tenants: false
        isMgr: isMgr
        # Parse turns dates into an object, which we must override.
        start_date: moment(@model.get "start_date").format("LL")
        end_date: moment(@model.get "end_date").format("LL")
        # Strings
        i18nUnit: i18nUnit
        i18nLease: i18nLease
        i18nCommon: i18nCommon
        baseUrl: @baseUrl
      @$el.html JST["src/js/templates/lease/show.jst"](vars)
      
      @$list = @$('ul#tenants')
      
      if @model.tenants.length is 0 then @model.tenants.fetch() else @addAll()
      @
      
    # We may have the network tenant list. Therefore, we must
    # be sure that we are only displaying relevant users.
    addOne : (t) =>
      if t.get("lease").id is @model.id
        @$("p.empty").text ''
        @$list.append (new TenantView(model: t)).render().el

    addAll : =>
      @model.tenants.chain().select((t) => t.get("lease").id is @model.id).each(@addOne)