define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/user"
  "i18n!nls/common"
  'templates/activity/list'
  'gmaps'
], ($, _, Parse, moment, Activity, i18nProperty, i18nListing, i18nUser, i18nCommon) ->

  class ActivityListView extends Parse.View
    
    tagName: "li"


    initialize: (attrs) ->
      
    # Re-render the contents of the Unit item.
    render: ->
      title = @model.get("title")
      rent = "$" + @model.get("rent")
      if @model.get('profile') 
        profilePic = @model.get('profile').cover("tiny")
        name = @model.get('profile').name()
      else 
        profilePic = @model.get('property').cover("tiny")
        name = @model.get('property').get("title")
      footer = """
              <footer></footer>
               """
      vars =
        publicUrl: @model.publicUrl()
        type: @model.get("activity_type")
        i18nCommon: i18nCommon
        i18nListing: i18nListing
        i18nProperty: i18nProperty
        i18nUser: i18nUser


      switch @model.get("activity_type")
        when "new_listing"
          cover = @model.get('property').cover("span6")
          vars.icon = 'listing'
          vars.content = """
                        <div class="photo photo-thumbnail stay-left">
                          <img class="" src="#{cover}" alt="#{i18nCommon.nouns.cover_photo}">
                        </div>
                        <div class="photo-float thumbnail-float caption">
                          <strong>#{title}</strong>
                          <div class="rent stay-right">#{rent}</div>
                          #{footer}
                        </div>
            """

        when "new_post"

          vars.icon = @model.get('post_type')
          # switch @model.get('post_type')
          #   when 'status'
          #   when 'question'
          #   when 'tip'
          #   when 'building'

          if @model.get "image"
            vars.content = """
                          <div class="row">
                            <div class="photo photo-span4">
                              <img src="#{@model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                            </div>
                          </div>
                          <div class="caption">
                            <strong>#{title}</strong>
                          </div>
                          """
          else
            vars.content = """
                          <blockquote>
                            #{title}
                          </blockquote>
                          """
          if @model.get("body") then vars.content += @model.get("body")
          vars.content += """
                        
                        #{footer}
                        """

        when "new_photo"
          vars.icon = 'photo'
          if @view.display is "small"
            vars.content = """
                          <div class="photo photo-thumbnail stay-left">
                            <img src="#{@model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                          </div>
                          <div class="photo-float thumbnail-float caption">
                            <strong>#{title}</strong>
                            #{footer}
                          </div>
              """
          else
            vars.content = """
                          <div class="row">
                            <div class="photo photo-span4">
                              <img src="#{@model.get("image")}" alt="#{i18nCommon.nouns.cover_photo}">
                            </div>
                          </div>
                          <div class="caption">
                            <strong>#{title}</strong>
                            #{footer}
                          </div>
                          """

        when "new_property"
          vars.icon = 'building'
          cover = @model.get('property').cover("span6")
          vars.content = """
                        <div class="photo photo-thumbnail stay-left">
                          <img class="" src="#{cover}" alt="#{i18nCommon.nouns.cover_photo}">
                        </div>
                        <div class="photo-float thumbnail-float caption">
                          <strong>#{title}</strong>
                          #{footer}
                        </div>
          """
        when "new_tenant"
          vars.icon = 'person'
          vars.content = """
                        <div class="photo">
                          <img src="#{@model.get('profile').cover("span6")}">
                          <div class="caption">
                            <h4>#{@model.get('profile').name()}</h4>
                          </div>
                        </div>
                        """
        when "new_manager"
          vars.icon = 'plus'
          vars.content = """
                        <div class="photo">
                          <img src="#{@model.get('profile').cover("span6")}">
                          <div class="caption">
                            <h4>#{@model.get('profile').name()}</h4>
                          </div>
                        </div>
                        """
        else
          vars.icon = ''
          vars.content = ""
      
      @$el.html JST["src/js/templates/activity/list.jst"](vars)

      @