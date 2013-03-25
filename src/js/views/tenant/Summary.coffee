define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  "i18n!nls/tenant"
  "i18n!nls/common"
  'templates/tenant/current'
], ($, _, Parse, Lease, i18nTenant, i18nCommon) ->

  class TenantSummaryView extends Parse.View
  
    tagName: "li"
  
    # Re-render the contents of the property item.
    render: ->
      vars = _.merge(
        @model.toJSON(),
        i18nTenant: i18nTenant
        i18nCommon: i18nCommon
      )
      $(@el).html JST["src/js/templates/tenant/current.jst"](vars)
      @