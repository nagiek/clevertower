define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  "collections/LeaseList"
  'models/Unit'
  'models/Lease'
  "views/lease/summary"
  "i18n!nls/unit"
  "i18n!nls/lease"
  "i18n!nls/common"
  'templates/unit/show'
], ($, _, Parse, moment, LeaseList, Unit, Lease, LeaseView, i18nUnit, i18nLease, i18nCommon) ->

  class ShowUnitView extends Parse.View
  
    el: ".content"
    
    initialize: (attrs) ->

      @property = attrs.property
      
      console.log @model
      @model.prep "leases"
      @model.leases.on "reset", @addAll
      @model.leases.on "add", @addOne
            
    # Re-render the contents of the Unit item.
    render: ->      
      modelVars = @model.toJSON()
      
      # References
      modelVars.propertyId = @property.id
      
      vars = _.merge(modelVars, i18nUnit: i18nUnit, i18nLease: i18nLease, i18nCommon: i18nCommon)
      $(@el).html JST["src/js/templates/unit/show.jst"](vars)
      
      @$list = @$('#leases-table tbody')
      @model.leases.fetch()
      
      @
      
    # Add all items in the Units collection at once.
    addAll: (collection, filter) =>
      @$list.html ''
      _.each @model.leases.where(unit: @model), @addOne

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (lease) =>
      @$('p.empty').hide()
      if lease.get("unit").id is @model.id
        view = new LeaseView(model: lease, onUnit: true)
        @$list.append view.render().el