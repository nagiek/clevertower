define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  'models/Profile'
  "i18n!nls/common"
  "i18n!nls/group"
  'templates/tenant/summary'
], ($, _, Parse, Lease, Profile, i18nCommon, i18nGroup) ->

  class TenantSummaryView extends Parse.View
  
    tagName: "li"
    className: "col-sm-6 col-md-4"
    
    events:
      'click .delete' : 'kill'
    
    initialize : (attrs) ->

      @showProperty = attrs.showProperty
      @showUnit = attrs.showUnit
      
      @listenTo @model, "destroy", @clear

      if @showUnit and Parse.User.current() 
        if Parse.User.current().get("network")
          @listenTo Parse.User.current().get("network").units, "reset", @addUnit
        else if Parse.User.current().get("property")
          @listenTo Parse.User.current().get("property").units, "reset", @addUnit
  
    # Re-render the contents of the property item.
    render: ->
      status = @model.get 'status'
      vars = _.merge @model.get("profile").toJSON(),
        i_status: i18nGroup.fields.status[status]
        status: status
        name: @model.get("profile").name()
        url: @model.get("profile").cover 'thumb'
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
        # To be overridden
        property: false
        unit: false

      if Parse.User.current() and (@showProperty or @showUnit)
          if Parse.User.current().get("network")
            if @showProperty
              property = Parse.User.current().get("network").properties.find((p) => p.id is @model.get("property").id)
              if property then vars.property = property.get("title")
            if @showUnit
              unit = Parse.User.current().get("network").units.find((u) => u.id is @model.get("unit").id)
              if unit then vars.unit = unit.get("title")
          if Parse.User.current().get("property")
            if @showProperty and Parse.User.current().get("property") and Parse.User.current().get("property").id is @model.get("property").id 
              vars.property = Parse.User.current().get("property").get("title")
            if @showUnit
              unit = Parse.User.current().get("property").units.find((u) => u.id is @model.get("unit").id)
              if unit then vars.unit = unit.get("title")

      @$el.html JST["src/js/templates/tenant/summary.jst"](vars)
      @

    # Units may not be queried yet. Stand by to add.
    addUnit: ->
      if Parse.User.current()
        if Parse.User.current().get("network")
          unit = Parse.User.current().get("network").units.find((u) => u.id is @model.get("unit").id)
        else if Parse.User.current().get("property")
          unit = Parse.User.current().get("property").units.find((u) => u.id is @model.get("unit").id)
          
        if unit then @$(".unit").html unit.get("title")
    
    kill: ->
      if confirm(i18nCommon.actions.confirm)
        @model.destroy()

    clear: =>
      @remove()
      @undelegateEvents()
      delete this
      