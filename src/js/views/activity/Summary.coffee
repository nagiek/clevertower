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
    
    tagName: "li"
    className: "span4 fade in"

    events:
      "mouseover > a" : "highlightMarker"
      "mouseout > a"  : "unHighlightMarker"
      # "click a" : "goToProperty"

    initialize: (attrs) ->
      
      @linkedToProperty = if attrs.linkedToProperty then true else false
      @marker = attrs.marker
      @view = attrs.view

      @listenTo @model, "refresh", @refresh
      @listenTo @model, "remove", @clear
      @listenTo @model.collection, "reset", @clear
      @listenTo @view, "view:changeDisplay", @setDisplay
      @listenTo @view, "model:viewDetails", @clear

      @id = "activity-#{@model.id}"
      
    # Re-render the contents of the Unit item.
    render: ->
      title = @model.get("title")

      if @model.get('profile') 
        profilePic = @model.get('profile').cover("tiny")
        name = @model.get('profile').name()
      else 
        profilePic = @model.get('property').cover("tiny")
        name = @model.get('property').get("title")
      footer = """
              <footer>
                <div class="photo photo-micro stay-left">
                  <img src="#{profilePic}" alt="#{name}" width="23" height="23">
                </div>
                <small class="photo-float micro-float">#{i18nCommon.fields.posted} #{moment(@model.createdAt).fromNow()}</small>   
              </footer>
               """

      vars =
        pos: @pos() # This will be incremented in the template.
        linkedToProperty: @linkedToProperty
        publicUrl: "#"
        type: @model.get("activity_type")
        i18nCommon: i18nCommon
        i18nListing: i18nListing
        i18nProperty: i18nProperty
        i18nUser: i18nUser

      if @linkedToProperty
        vars.propertyId = @model.get("property").id
        vars.publicUrl = @model.get("property").publicUrl()

      switch @model.get("activity_type")
        when "new_listing"
          cover = @model.get('property').cover("span6")
          rent = "$" + @model.get("rent")
          vars.icon = 'listing'
          if @view.display is "small"
            vars.content = """
                          <div class="photo photo-thumbnail stay-left">
                            <img src="#{cover}" alt="#{i18nCommon.nouns.cover_photo}">
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
                              <img src="#{cover}" alt="#{i18nCommon.nouns.cover_photo}">
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
      
      @$el.html JST["src/js/templates/activity/summary.jst"](vars)

      unless @marker
        @marker = new google.maps.Marker
          position: @model.GPoint()
          map: @view.map
          ZIndex: 1
          icon: 
            url: "/img/icon/pins-sprite.png"
            size: new google.maps.Size(25, 32, "px", "px")
            origin: new google.maps.Point(0, @pos() * 32)
            anchor: null
            scaledSize: null

      @highlightListener = google.maps.event.addListener @marker, "mouseover", @highlightMarker
      @unHighlightListener = google.maps.event.addListener @marker, "mouseout", @unHighlightMarker
      @clickListener = google.maps.event.addListener @marker, "click", @goToProperty

      @

    # This fn needed to correctly set this attribute from within an event.
    setDisplay: (display) => @display = display; @render()

    undelegateEvents: =>
      google.maps.event.removeListener @highlightListener
      google.maps.event.removeListener @unHighlightListener
      super

    goToProperty: (e) =>
      e.preventDefault()
      @view.trigger "model:view", @model
      # require ["views/property/Public"], (PublicPropertyView) => 
      #   p = @model.get("property")
      #   # Could assign a place from last search, but we don't know for sure.
      #   new PublicPropertyView(model: p).render()
      #   Parse.history.navigate p.publicUrl()
        

    highlightMarker : =>
      @$('> a').addClass('active')
      icon = @marker.icon
      icon.origin = new google.maps.Point(icon.origin.x + 25, icon.origin.y)
      @marker.setIcon icon
      # @marker.setZIndex 100
      

    unHighlightMarker : =>
      @$('> a').removeClass('active')
      icon = @marker.icon
      icon.origin = new google.maps.Point(icon.origin.x - 25, icon.origin.y)
      @marker.setIcon icon
      # @marker.setZIndex 1

    clear : => 
      @marker.setMap null
      @remove()
      @undelegateEvents()
      delete this

    refresh : ->
      icon = @marker.icon
      icon.origin = new google.maps.Point(icon.origin.x, @pos() * 32)
      @marker.setIcon icon
      @$(".position").html @pos() + 1

    pos : ->
      if @linkedToProperty then @model.get("property").pos() else @model.pos()