define [
  "jquery"
  "underscore"
  "backbone"
  'collections/lease/LeaseList'
  'models/Property'
  'models/Lease'
  'views/helper/Alert'
  'views/lease/Summary'
  "i18n!nls/common"
  "i18n!nls/property"
  "i18n!nls/unit"
  "i18n!nls/lease"
  'templates/property/sub/leases'
], ($, _, Parse, LeaseList, Property, Lease, Alert, LeaseView, i18nCommon, i18nProperty, i18nUnit, i18nLease) ->

  class PropertyLeasesView extends Parse.View
  
    el: ".content"
        
    initialize: (attrs) ->
      @editing = false
      
      @on "view:change", @clear
      
      @model.prep('leases')
      @model.leases.on "add", @addOne
      @model.leases.on "reset", @addAll

    render: =>
      vars = _.merge(i18nProperty: i18nProperty, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease)
      @$el.html JST["src/js/templates/property/sub/leases.jst"](vars)
      
      @$table     = @$("#leases-table")
      @$list      = @$("#leases-table tbody")
      @$actions   = @$(".form-actions")
      @$undo      = @$actions.find('.undo')

      # Fetch all the property items for this user
      if @model.leases.length is 0 then @model.leases.fetch() else @addAll()
      @
    
    clear: (e) =>
      @undelegateEvents()
      delete this

    # Add all items in the Leases collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      # TODO: This is getting triggered with a phantom model
      if @model.leases.length > 0 then @model.leases.each @addOne
      else @$list.html '<p class="empty">' + i18nLease.collection.empty + '</p>'

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (lease) =>
      @$('p.empty').hide()
      view = new LeaseView(model: lease)
      console.log lease
      console.log view
      @$list.append view.render().el
      view.$el.find('.view-specific').toggleClass('hide') if @editing