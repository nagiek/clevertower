define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  "i18n!nls/property"
  "i18n!nls/common"
  'templates/property/result'
  'gmaps'
], ($, _, Parse, Property, i18nProperty, i18nCommon) ->

  class PropertyResultView extends Parse.View
  
    tagName: "li"
    className: "result media clearfix lifted position-relative"

    events:
      'click .join'         : 'join'
  
    initialize: (attrs) =>
      @forNetwork = if attrs.forNetwork then attrs.forNetwork else false
      @view = attrs.view
      @listenTo @model, "remove", @clear

    render: =>
      vars = 
        formatted_address: @model.get "formatted_address"
        cover:             @model.get('profile').cover('profile')
        pos:               @model.pos() + 1
        publicUrl:         @model.publicUrl()
        i18nCommon:        i18nCommon
        forNetwork:        @forNetwork
      
      @$el.html JST["src/js/templates/property/result.jst"](vars)
      @marker = new google.maps.Marker 
        position: @model.GPoint()
        map: @view.gmap
        ZIndex:   1
        icon: 
          url: "/img/icon/pins-sprite.png"
          size: new google.maps.Size(25, 32, "px", "px")
          origin: new google.maps.Point(0, @model.pos() * 32)
          anchor: null
          scaledSize: null
      @

    join: ->
      if @forNetwork
        @view.trigger "property:manage", @model
      else 
        @view.trigger "property:join", @model

    clear: =>
      @marker.setMap null
      @remove()
      delete this