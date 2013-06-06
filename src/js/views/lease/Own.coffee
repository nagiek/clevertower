define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'views/helper/Alert'
  "i18n!nls/common"
  'templates/lease/own'
], ($, _, Parse, moment, Alert, i18nCommon) ->

  class OwnLeaseView extends Parse.View
  
    tagName: "li"
    className: "row"

    events:
      'click .make-primary' : 'makePrimary'
      
    initialize: (attrs) ->
      @listenTo Parse.User.current(), "change:lease", @render

    # Re-render the contents of the Unit item.
    render: ->
      
      vars = 
        primary: Parse.User.current().get("lease") and Parse.User.current().get("lease") is @model.get("lease").id 
        start_date: moment(@model.get("lease").get("start_date")).format("LL")
        end_date: moment(@model.get("lease").get("end_date")).format("LL")
        unitTitle: @model.get("lease").get("unit").get("title")
        propertyUrl: @model.get("property").publicUrl()
        propertyTitle: @model.get("property").get("title")
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/lease/own.jst"](vars)
      @ 

    makePrimary : (e) =>
      e.preventDefault()

      Parse.User.current().save
        lease: @model.get("lease")
        unit: @model.get("lease").get("unit")
        property: @model.get("property")
      .then -> 
        new Alert event: 'model-save', fade: true, message: i18nCommon.actions.changes_saved, type: 'success'