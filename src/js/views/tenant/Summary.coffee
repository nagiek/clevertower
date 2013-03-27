define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  "i18n!nls/tenant"
  "i18n!nls/common"
  'templates/tenant/summary'
], ($, _, Parse, Lease, i18nTenant, i18nCommon) ->

  class TenantSummaryView extends Parse.View
  
    tagName: "li"

    initialize: ->
      @user = new Parse.User @model.get("user").attributes
      @render()
  
    # Re-render the contents of the property item.
    render: ->
      vars = _.merge(
        @user.toJSON(),
        status: @model.get 'status'
        url: @user.cover 'thumb'
        objectId: @user.id
        i18nTenant: i18nTenant
        i18nCommon: i18nCommon
      )
      JST["src/js/templates/tenant/summary.jst"](vars)