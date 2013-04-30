define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  "i18n!nls/user"
  "i18n!nls/common"
], ($, _, Parse, moment, Activity, i18nUser, i18nCommon) ->

  class InquirySummaryView extends Parse.View
    
    tagName: "tr"

    events:
      'click .delete'     : 'kill'
      
    initialize: (attrs) ->

      _.bindAll @, 'render', 'kill', 'addOne', 'addAll'
        
      @model.on "destroy", =>
        @remove()
        @undelegateEvents()
        delete this
      
      @model.prep('applicants')

    # Re-render the contents of the Unit item.
    render: ->
      vars =
        createdAt: moment(@model.createdAt).format("LL")
        i18nCommon: i18nCommon
        i18nUser: i18nUser
      $(@el).html "<p>activity</p>"



      @$list = @$('ul.applicants')
      @addAll()

      @

    # We may have the network tenant list. Therefore, we must
    # be sure that we are only displaying relevant users.
    addOne : (a) =>
      if a.get("inquiry").id is @model.id
        @$(".empty").remove()
        @$list.append (new ApplicantView(model: a)).render().el

    addAll : =>
      @$list.html ""
      visible = @model.applicants.where(inquiry: @model)
      _.each visible, @addOne

    kill : (e) ->
      e.preventDefault()
      @model.destroy()