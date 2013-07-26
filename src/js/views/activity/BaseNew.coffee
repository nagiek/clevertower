define [
  "jquery"
  "underscore"
  "backbone"
  "models/Activity"
  "views/helper/Alert"
  "views/activity/Summary"
  'views/user/AppsModal'
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/activity/new"
  "templates/activity/pending_photo"
  "templates/activity/photo"
  'gmaps'
  "datepicker"
  'jquery.fileupload'
  'jquery.fileupload-fp'
  'jquery.fileupload-ui'
], ($, _, Parse, Activity, Alert, ActivityView, AppsModalView, i18nUser, i18nProperty, i18nCommon) ->

  class BaseNewActivityView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.

    events:
      # Share options
      "change #fbShare"                 : "checkShareOnFacebook"

    # If the account is unlinked to FB but the user wants to share, get them to connect first.
    # 
    checkShareOnFacebook: (e) =>
      # Ignore if the user is connected, or if it is set to false.
      return if Parse.User.current()._isLinked("facebook") or @$("#fbShare :eq[0]").is("checked")
      # If the user is not linked, set the toggle to "false" and prompt the user to connect.
      e.preventDefault()
      @$("#fbShare eq[0]").prop "checked", true
      @$("#fbShare eq[1]").prop "checked", false
      if @appsModal then @appsModal.$el.modal("show") else @appsModal = new AppsModalView().render()

    clear : =>
      @appsModal.clear() if @appsModal
      @undelegateEvents()
      @remove()
      delete this