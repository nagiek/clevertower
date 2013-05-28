define [
  "jquery"
  "underscore"
  "backbone"
  'collections/TenantList'
  'models/Tenant'
  'models/Profile'
  'views/helper/Alert'
  'views/tenant/Summary'
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/network/sub/tenants'
], ($, _, Parse, TenantList, Tenant, Profile, Alert, TenantView, i18nGroup, i18nCommon) ->

  class NetworkTenantsView extends Parse.View
    
    events:
      'click .nav a' : 'filter'
    
    initialize: (attrs) ->
      
      _.bindAll this, 'addOne', 'addAll', 'render', 'filter'

      @currentFilter = 'filter-all'

      @model.prep('tenants')
      
      @model.tenants.on "add",   @addOne
      @model.tenants.on "reset", @addAll

      @render()
      
    # Re-render the contents of the Unit item.
    render: ->
      
      vars = _.merge(i18nGroup: i18nGroup, i18nCommon: i18nCommon)
      @$el.html JST["src/js/templates/network/sub/tenants.jst"](vars)

      @$filters = @$('.nav')
      @$list = @$('#tenants')

      if @model.tenants.length is 0 then @model.tenants.fetch() else @addAll()
      @
      
    addOne : (tenant) ->
      @$list.append (new TenantView(model: tenant)).render().el

    addAll : (e) ->

      @filter(e)

      @$filters.find(".filter-all .count").html @model.tenants.length      
      @$filters.find(".filter-recent .count").html @model.tenants.filterRecent().length

    filter : (e) ->
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