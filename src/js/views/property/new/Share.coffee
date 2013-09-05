define [
  "jquery"
  "underscore"
  "backbone"
  "models/Activity"
  'views/activity/BaseNew'
  'views/user/AppsModal'
  "i18n!nls/property"
  "i18n!nls/common"
  "plugins/toggler"
  'templates/property/new/share'
], ($, _, Parse, Activity, BaseNewActivityView, AppsModalView, i18nProperty, i18nCommon) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class SharePropertyView extends BaseNewActivityView

    tagName: "form"
    id: "new-property-activity-form"
    className: "activity-form col-xs-12"

    # attributes:
    #   id: "new-property-activity-form"
    #   class: "activity-form span12"
    #   style: "left: 0%;"

    events:
      "toggle:on .post-group .toggle": "enableActivityView"
      "toggle:off .post-group .toggle": "disableActivityView"
      # Original from BaseNewActivityView.
      "toggle:on .facebook-group .toggle": "checkShareOnFacebook"

    initialize: (attrs) ->
      
      @wizard = attrs.wizard
      @listenTo @wizard, "wizard:finish wizard:cancel", @clear
        
    render : ->

      vars = 
        title: i18nProperty.activity.new_property()
        cover: @model.cover("large")
        profilePic: Parse.User.current().get("profile").cover("tiny")
        fbLinked: Parse.User.current()._isLinked("facebook")
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/property/new/share.jst"](vars)
      @$(".toggle").each -> $(this).toggler()

      @

    enableActivityView : => @$("#sample-activity").find('.mask').addClass("hide")
    disableActivityView : => @$("#sample-activity").find('.mask').removeClass("hide")