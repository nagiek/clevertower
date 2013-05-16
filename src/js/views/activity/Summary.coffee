define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  "i18n!nls/property"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/activity/summary'
  'gmaps'
], ($, _, Parse, moment, Activity, i18nProperty, i18nUser, i18nCommon) ->

  class ActivitySummaryView extends Parse.View
    
    tagName: "li"

    initialize: (attrs) ->
      @property = attrs.property
      
    # Re-render the contents of the Unit item.
    render: ->

      vars =
        createdAt: moment(@model.createdAt).format("LL")
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty
        i18nUser: i18nUser
      switch @model.get("type")
      when "new_listing"
        vars.content = """
                      <div class="photo">
                        <img src="#{@property.cover("span6")}">
                        <div class="caption">
                          <h4>#{@model.get('title')}</h4>
                        </div>
                      </div>
                      """
        
      when "new_tenant"
        vars.content = """
                      <div class="photo">
                        <img src="#{@model.get('profile').cover("span6")}">
                        <div class="caption">
                          <h4>#{@model.get('profile').name()}</h4>
                        </div>
                      </div>
                      """
      when "new_manager"
        vars.content = """
                      <div class="photo">
                        <img src="#{@model.get('profile').cover("span6")}">
                        <div class="caption">
                          <h4>#{@model.get('profile').name()}</h4>
                        </div>
                      </div>
                      """
      when "new_post"
        vars.content = """
                      <div class="photo">
                        <img src="#{@model.get('profile').cover("span6")}">
                        <div class="caption">
                          <h4>#{@model.get('profile').name()}</h4>
                        </div>
                      </div>
                      """
      when "new_photo"
      
      @$el.html JST["src/js/templates/activity/summary.jst"](vars)

      @