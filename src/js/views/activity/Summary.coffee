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
  'templates/activity/summary'
  'gmaps'
], ($, _, Parse, moment, Activity, i18nProperty, i18nListing, i18nUser, i18nCommon) ->

  class ActivitySummaryView extends Parse.View
    
    # tagName: "div"
    
    # events:
    #   "mouseover this"       : "highlightMarker"
    #   "mouseout this"        : "unHighlightMarker"
      # "click a" : "goToProperty"

    initialize: (attrs) ->
      
      @linkedToProperty = if attrs.linkedToProperty then true else false
      @marker = attrs.marker
      @view = attrs.view
      @liked = attrs.liked || false
      @pos = attrs.pos || @getPosition()


      # @listenTo @model, "refresh", @refresh
      # @listenTo @model, "remove", @clear
      # @listenTo @model.collection, "reset", @clear
      # @listenTo @view, "view:changeDisplay", @setDisplay
      # @listenTo @view, "model:viewDetails", @clear

    # Re-render the contents of the Unit item.
    render: ->
      title = @model.get("title")

      if @model.get('profile') 
        name = @model.get('profile').name()
      else 
        name = @model.get('property').get("title")
      footer = """
              <footer>
                <div class="photo photo-micro stay-left">
                  <img alt="#{name}" width="23" height="23">
                </div>
                <small class="photo-float micro-float">#{i18nCommon.fields.posted} #{moment(@model.createdAt).fromNow()}</small>   
              </footer>
               """

      vars =
        liked: @liked
        pos: @pos % 20 # This will be incremented in the template.
        linkedToProperty: @linkedToProperty
        publicUrl: "#"
        type: @model.get("activity_type")
        i18nCommon: i18nCommon
        i18nListing: i18nListing
        i18nProperty: i18nProperty
        i18nUser: i18nUser

      @$el.attr
        id: "activity-#{@model.id}"
        class: "thumbnail clearfix activity fade in"
        "data-liked": if @liked then "true" else "false"
        "data-property-index": if @model.get("property") then @model.get("property").pos() else false
        # "data-property-id": if @model.get("property") then @model.get("property").id else false
        "data-index": @model.pos()
        "data-lat": @model.GPoint().lat()
        "data-lng": @model.GPoint().lng()
        "data-collection": if @linkedToProperty then "user" else "external"
        "data-profile": if @model.get('property') and not @model.get('profile') then @model.get('property').cover("tiny") else @model.get('profile').cover("tiny")
        "data-image": switch @model.get("activity_type")
          when "new_listing", "new_property"
            @model.get('property').cover("span6")
          when "new_post", "new_photo"
            @model.get("image") || false
          when "new_tenant", "new_manager"
            @model.get('profile').cover("span6")
          else
            false

      if @linkedToProperty
        vars.propertyId = @model.get("property").id
        vars.publicUrl = @model.get("property").publicUrl()

      switch @model.get("activity_type")
        when "new_listing"
          cover = @model.get('property').cover("span6")
          rent = "$" + @model.get("rent")
          vars.icon = 'listing'
          vars.image = cover
          if @view.display is "small"
            vars.content = """
                          <div class="photo photo-thumbnail stay-left">
                            <img alt="#{i18nCommon.nouns.cover_photo}">
                          </div>
                          <div class="photo-float thumbnail-float caption">
                            <strong>#{title}</strong>
                            <div class="rent stay-right">#{rent}</div>
                            #{footer}
                          </div>
              """
          else
            vars.content = """
                          <div class="row">
                            <div class="photo photo-span4">
                              <img alt="#{i18nCommon.nouns.cover_photo}">
                            </div>
                          </div>
                          <div class="caption">
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
            vars.image = @model.get "image"
            vars.content = """
                          <div class="row">
                            <div class="photo photo-span4">
                              <img alt="#{i18nCommon.nouns.cover_photo}">
                            </div>
                          </div>
                          <div class="caption">
                          """
            vars.content += "<p><strong>#{title}</strong></p>" if @model.get "title"
            if @model.get "isEvent"
              vars.content += "<p><strong>#{moment(@model.get("startDate")).format("LLL")}"
              vars.content += " - #{moment(@model.get("endDate")).format("h:mm a")}" if @model.get "endDate"
              vars.content += "</strong></p>"
            vars.content += """
                            #{footer}
                          </div>
                          """
          else
            vars.image = false
            vars.content = """
                          <blockquote>
                            #{title}
                          </blockquote>
                          <div class="caption">
                          """
            if @model.get "isEvent"
              vars.content += "<p><strong>#{moment(@model.get("startDate")).format("LLL")}"
              vars.content += " - #{moment(@model.get("endDate")).format("h:mm a")}" if @model.get "endDate"
              vars.content += "</strong></p>"
            vars.content += """
                            #{footer}
                          </div>
                          """

        when "new_photo"
          vars.icon = 'photo'
          vars.image = @model.get "image"
          if @view.display is "small"
            vars.content = """
                          <div class="photo photo-thumbnail stay-left">
                            <img alt="#{i18nCommon.nouns.cover_photo}">
                          </div>
                          <div class="photo-float thumbnail-float caption">
                            """
            vars.content += "<p><strong>#{title}</strong></p>" if @model.get "title"
            vars.content += """
                            #{footer}
                          </div>
              """
          else
            vars.content = """
                          <div class="row">
                            <div class="photo photo-span4">
                              <img alt="#{i18nCommon.nouns.cover_photo}">
                            </div>
                          </div>
                          <div class="caption">
                            """
            vars.content += "<p><strong>#{title}</strong></p>" if @model.get "title"
            vars.content += """
                            #{footer}
                          </div>
                          """

        when "new_property"
          vars.icon = 'building'
          vars.image = @model.get('property').cover("span6")
          vars.content = """
                        <div class="photo photo-thumbnail stay-left">
                          <img class="" alt="#{i18nCommon.nouns.cover_photo}">
                        </div>
                        <div class="photo-float thumbnail-float caption">
                            <p><strong>#{title}</strong></p>
                          #{footer}
                        </div>
          """
        when "new_tenant"
          vars.icon = 'person'
          vars.image = @model.get('profile').cover("span6")
          vars.content = """
                        <div class="photo">
                          <img>
                          <div class="caption">
                            <h4>#{@model.get('profile').name()}</h4>
                          </div>
                        </div>
                        """
        when "new_manager"
          vars.icon = 'plus'
          vars.image = @model.get('profile').cover("span6")
          vars.content = """
                        <div class="photo">
                          <img>
                          <div class="caption">
                            <h4>#{@model.get('profile').name()}</h4>
                          </div>
                        </div>
                        """
        else
          vars.icon = ''
          vars.image = false
          vars.content = ""
      
      @$el.html JST["src/js/templates/activity/summary.jst"](vars)

      # @clickListener = google.maps.event.addListener @marker, "click", @goToProperty

      @

    # This fn needed to correctly set this attribute from within an event.
    setDisplay: (display) => @display = display; @render()

    # undelegateEvents: =>
    #   google.maps.event.removeListener @highlightListener
    #   google.maps.event.removeListener @unHighlightListener
    #   super

    # goToProperty: (e) =>
    #   e.preventDefault()
    #   @view.trigger "model:view", @model
    #   require ["views/property/Public"], (PublicPropertyView) => 
    #     p = @model.get("property")
    #     # Could assign a place from last search, but we don't know for sure.
    #     new PublicPropertyView(model: p).render()
    #     Parse.history.navigate p.publicUrl()

    clear : => 
      @marker.setMap null if @marker
      @remove()
      @undelegateEvents()
      delete this

    refresh : ->
      @pos = @getPosition()
      @$(".position").html @pos + 1
      if @marker
        icon = @marker.icon
        icon.origin = new google.maps.Point(icon.origin.x, @pos * 32)
        @marker.setIcon icon

    getPosition: => if @linkedToProperty then @model.get("property").pos() else @model.pos()
