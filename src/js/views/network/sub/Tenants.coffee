define [
  "jquery"
  "underscore"
  "backbone"
  'collections/TenantList'
  'models/Tenant'
  'models/Profile'
  'views/helper/Alert'
  'views/tenant/Summary'
  "i18n!nls/lease"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/network/sub/tenants'
], ($, _, Parse, TenantList, Tenant, Profile, Alert, TenantView, i18nLease, i18nGroup, i18nCommon) ->

  class NetworkTenantsView extends Parse.View
    
    events:
      'click .nav a' : 'filter'
    
    initialize: (attrs) ->

      @baseUrl = attrs.baseUrl

      @currentFilter = 'filter-all'

      @model.prep('tenants')
      
      @listenTo @model.tenants, "add",   @addOne
      @listenTo @model.tenants, "reset", @addAll

      @render()
      
    # Re-render the contents of the Unit item.
    render: =>
      
      vars = 
        i18nLease: i18nLease
        i18nGroup: i18nGroup
        i18nCommon: i18nCommon
        baseUrl: @baseUrl
      @$el.html JST["src/js/templates/network/sub/tenants.jst"](vars)

      @$filters = @$('.nav')
      @$list = @$('#tenants')

      if @model.tenants.length is 0 then @model.tenants.fetch() else @addAll()
      @
      
    addOne : (tenant) =>
      @$list.append (new TenantView(model: tenant)).render().el

    addAll : (e) =>

      @filter(e)

      @$filters.find(".filter-all .count").html @model.tenants.length      
      @$filters.find(".filter-recent .count").html @model.tenants.filterRecent().length

    filter : (e) =>
      @currentFilter = e.currentTarget.className if e and e.currentTarget
      @$list.html ""
      @$list.removeClass "in"

      # Filter the collection.
      @$filters.find('li').removeClass('active')
      @$filters.find(".#{@currentFilter}").parent().addClass('active')
      visible = switch @currentFilter
        when 'filter-all'     then @model.tenants.models
        when 'filter-recent'  then @model.tenants.filterRecent()
      if visible.length is 0 then @$list.html "<li class='span'>#{i18nGroup.tenant.empty.index}</li>"
      else _.each visible, @addOne
      
      @$list.addClass "in"