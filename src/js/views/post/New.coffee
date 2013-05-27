define [
  "jquery"
  "underscore"
  "backbone"
  "models/Post"
  "models/Activity"
  "views/activity/Summary"
  "i18n!nls/user"
  "i18n!nls/property"
  "i18n!nls/common"
  "templates/post/new"
  'gmaps'
], ($, _, Parse, Post, Activity, ActivityView, i18nUser, i18nProperty, i18nCommon) ->

  class NewPostView extends Parse.View
  
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#user-container"

    events:
      "submit form"                     : "post"
      "focus #post-title"               : "showPostForm"
      "change #show-body"               : "toggleBodyView"
      "change #centered-on-property"    : "toggleCenterOnProperty"
      "click #post-type li input"       : "handlePostClick"
      "change #property-options select" : "centerOnNetworkProperty"
    
    initialize: (attrs) ->

      @model = new Post
      @view = attrs.view
      @listenTo Parse.Dispatcher, "user:logout", @clear

      @listenTo @view, "dragend", @updateCenter
      @updateCenter()

      @on "property:change", (property) =>
        @model.set "property", property
        if property
          @view.map.setCenter property.GPoint()
          @view.map.setZoom 14


    updateCenter : => center = @view.map.getCenter(); @model.set "center", new Parse.GeoPoint(center.lat(), center.lng())

    handlePostClick : =>
      index = @getTypeIndex()
      pos = @$("#post-input-caret").data "position"
      if index is pos 
        if @shown then @hidePostForm() else @showPostForm()
      else
        @changePostType()
        @checkMarkerVisibility()

    changePostType : ->

      rand = Math.floor Math.random() * i18nUser.form.share[0].length

      index = @getTypeIndex()
      pos = @$("#post-input-caret").data "position"

      @$("#post-input-caret").addClass "phase-#{index}"
      @$("#post-input-caret").removeClass "phase-#{pos}"
      @$("#post-input-caret").data "position", index
      @$("#post-title").prop 'placeholder', i18nUser.form.share[index][rand]

    checkMarkerVisibility: ->
      if @getTypeIndex() is 3
        # TODO: unable to set checkbox to 'checked' AND 'disabled'
        @$("#centered-on-property").prop('checked', true).trigger("change") unless $("#redo-search").is(":checked")
        @$("#centered-on-property").prop('disabled', true)
      else
        @marker.setVisible true
        @$("#centered-on-property").removeProp("disabled")

    getTypeIndex: -> @$("#post-type :checked").parent().index()

    render: =>

      @marker = new google.maps.Marker
        position:   @view.map.getCenter()
        map:        @view.map
        animation:  google.maps.Animation.DROP
        ZIndex:     101
        visible:    false

      @empty = false

      vars = 
        i18nCommon: i18nCommon
        i18nProperty: i18nProperty

      @$el.html JST["src/js/templates/post/new.jst"](vars)

      rand = Math.floor Math.random() * i18nUser.form.share.length
      @$("#post-type :nth-child(#{rand + 1}) input").prop('checked', true)
      @changePostType()
      @$('[rel=tooltip]').tooltip()

      if Parse.User.current().get("property")
        @$("#property-options").html "<strong>#{Parse.User.current().get("property").get("title")}</strong>"

      else if Parse.User.current().get("network")

        # Render asynchronously, while we wait for the property
        # info to come in so we can determine our center & radius
        @$("#property-options").html "<select></select>"
        if Parse.User.current().get("network").properties.length is 0
          @handleNoProperty()
          @listenToOnce Parse.User.current().get("network").properties, "reset", @populatePropertySelect
        else
          @populatePropertySelect()
          
      else
        @handleNoProperty()
       
      @

    populatePropertySelect : ->
      if Parse.User.current().get("network").properties.length > 0
        propertyOptions = ''
        Parse.User.current().get("network").properties.each (p) -> 
          propertyOptions += "<option value='#{p.id}'>#{p.get("title")}</option>"
        @$("#property-options > select").html propertyOptions
      else
        @handleNoProperty()

    handleNoProperty : ->
      @empty = true
      if Parse.User.current().get("network")
        @$('.empty').html """
                          <a href='#{Parse.User.current().get("network").privateUrl()}'>
                            #{i18nProperty.actions.add_a_property_to_start}
                          </a>
                          """
      else 
        @$('.empty').html """
                    <a href='/network/set'>
                      #{i18nProperty.actions.join_or_create_a_property_to_start}
                    </a>
                    """

    showPostForm : (e) => 
      return if @shown
      @shown = true
      @$('#post-options').removeClass 'hide'
      @marker.bindTo 'position', @view.map, 'center' 
      @checkMarkerVisibility()
      $("#redo-search").prop('checked', false).trigger("change") if $("#redo-search").is(":checked")

    hidePostForm : (e) => 
      return unless @shown
      @shown = false
      @$('#post-title').val('').blur()
      @$('#post-options').addClass 'hide'
      @marker.setVisible false
    
    toggleCenterOnProperty: (e) =>

      if e.currentTarget.checked
        @marker.setVisible false
        @$('#property-options').removeClass 'hide'
        
        if Parse.User.current().get("property") 
          @trigger "property:change", Parse.User.current().get("property")
        else if Parse.User.current().get("network") then @centerOnNetworkProperty()

      else
        @marker.setVisible true
        @$('#property-options').addClass 'hide'


    centerOnNetworkProperty : =>
      p = @$('#property-options select :selected').val()
      @trigger "property:change", Parse.User.current().get("network").properties.get(p)


    toggleBodyView : (e) =>
      if e.currentTarget.checked then @$('.body-group').removeClass 'hide'
      else @$('.body-group').addClass 'hide'


    post : (e) ->
      e.preventDefault() if e

      @$('button.save').prop "disabled", "disabled"
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')


      @model.save data.post,
        success: (model) => 
          model.set 
            activity_type: "new_post"
            profile: Parse.User.current().profile
          # Add to appropriate collection
          if model.get("property")
            Parse.User.current().add new Activity(model.attributes)
          else Parse.App.activity.add new Activity(model.attributes)

          @view.refreshDisplay()

          # Reset
          @model = new Post
          @marker.setMap null
          @undelegateEvents()
          @render()
          @delegateEvents()
        error: (model, error) => console.log error

    clear: (e) =>
      @$el.html ""
      @stopListening()
      @undelegateEvents()
      delete this