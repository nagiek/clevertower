define [
  "jquery"
  "underscore"
  "backbone"
  "moment"
  'models/Activity'
  "i18n!nls/common"
  'templates/activity/summary'
  'gmaps'
], ($, _, Parse, moment, Activity, i18nCommon) ->

  class ActivitySummaryView extends Parse.View
    
    # tagName: "div"
    className: "thumbnail clearfix activity fade in"
    
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

      vars = _.merge @model.toJSON(), 
        url: @model.url()
        pos: @pos % 20 # This will be incremented in the template.
        linkedToProperty: @linkedToProperty
        start: moment(@model.get("startDate")).format("LLL")
        end: moment(@model.get("endDate")).format("LLL")
        postDate: moment(@model.createdAt).fromNow()
        liked: @liked
        icon: @model.icon()
        name: @model.name()
        profilePic: @model.profilePic("tiny")
        pos: @pos % 20 # This will be incremented in the template.
        i18nCommon: i18nCommon

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likeCount: 0
        commentCount: 0

      # Override default title.
      vars.title = @model.title()

      # Extra details for infinity.js
      @$el.attr
        id: "activity-#{@model.id}"
        "data-liked": if @liked then "true" else "false"
        "data-property-index": if @model.get("property") then @model.get("property").pos() else false
        # "data-property-id": if @model.get("property") then @model.get("property").id else false
        "data-index": @model.pos()
        "data-lat": @model.GPoint().lat()
        "data-lng": @model.GPoint().lng()
        "data-collection": if @linkedToProperty then "user" else "external"
        "data-profile": @model.profilePic()
        "data-image": @model.image()

      @$el.html JST["src/js/templates/activity/summary.jst"](vars)

      @

    # This fn needed to correctly set this attribute from within an event.
    # setDisplay: (display) => @display = display; @render()

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

    # clear : => 
    #   @marker.setMap null if @marker
    #   @remove()
    #   @undelegateEvents()
    #   delete this

    # refresh : ->
    #   @pos = @getPosition()
    #   @$(".position").html @pos + 1
    #   if @marker
    #     icon = @marker.icon
    #     icon.origin = new google.maps.Point(icon.origin.x, @pos * 32)
    #     @marker.setIcon icon

    getPosition: => if @linkedToProperty then @model.get("property").pos() else @model.pos()
