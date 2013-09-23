define [
  "jquery"
  "underscore"
  "backbone"
  "views/activity/List"
  "views/activity/BaseIndex"
  "views/photo/Public"
  "views/listing/PublicSummary"
  "i18n!nls/property"
  "i18n!nls/listing"
  "i18n!nls/unit"
  "i18n!nls/group"
  "i18n!nls/common"
  'templates/property/public'
  'templates/activity/modal'
  'templates/comment/summary'
  "gmaps"
], ($, _, Parse, ActivityView, BaseIndexActivityView, PhotoView, ListingView, i18nProperty, i18nListing, i18nUnit, i18nGroup, i18nCommon) ->

  class PublicPropertyView extends BaseIndexActivityView

    el: '#main'

    events:
      'click .nav a'                        : 'showTab'
      'click #activity ul > li > a.content' : 'showModal'
      'click #new-lease'                    : 'showLeaseModal'
      # Activity events
      "click .like-button"                  : "likeOrLogin"
      "click .likers"                       : "showLikers"
      "submit form.new-comment-form"        : "postComment"

    initialize: (attrs) ->

      super

      @place = if attrs.place then attrs.place else @model.city()

      @mapId = "mapCanvas"

      @model.prep "activity"
      @model.prep "comments"
      @model.prep "photos"
      @model.prep "listings"

      @listenTo @model.activity, "add", @addOneActivity
      @listenTo @model.activity, "reset", @addAllActivity

      @listenTo @model.photos, "add", @addOnePhoto
      @listenTo @model.photos, "reset", @addAllPhotos

      @model.listings.title = @model.get "title"
      @listenTo @model.listings, "add", @addOneListing
      @listenTo @model.listings, "reset", @addAllListings

    showTab : (e) ->
      e.preventDefault()
      $("#{e.currentTarget.hash}-link").tab('show')

    render: ->

      vars =
        property: @model.toJSON()
        place: @place
        cover: @model.cover('span9')
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        i18nGroup: i18nGroup
        i18nListing: i18nListing
        i18nUnit: i18nUnit

      @$el.html JST["src/js/templates/property/public.jst"](vars)

      center = @model.GPoint()

      map = new google.maps.Map document.getElementById(@mapId), 
        zoom          : 15
        center        : center
        mapTypeId     : google.maps.MapTypeId.ROADMAP

      if @model.get "approx"
        marker = new google.maps.Circle
          center:         center
          map:            map
          radius:         250
          fillColor:      "#f8aa6f"
          fillOpacity:    0.5
          strokeColor:    "#f28255"
          strokeOpacity:  0.8
          strokeWeight:   3
      else
        marker = new google.maps.Marker
          position: center
          map:      map
          animation: google.maps.Animation.DROP
          icon: 
            url: "/img/icon/pins-sprite.png"
            size: new google.maps.Size(25, 32, "px", "px")
            origin: new google.maps.Point(0, 0)
            anchor: null
            scaledSize: null

      @$activity = @$("#activity ul")
      @$photos = @$("#photos ul")
      @$listings = @$("#listings > table > tbody")
      
      if @model.activity.length > 0 then @addAllActivity() else @model.activity.fetch()
      if @model.photos.length > 0 then @addAllPhotos() else @model.photos.fetch()
      if @model.listings.length > 0 then @addAllListings() else @model.listings.fetch()

      @

    # Activity
    # ------

    addOneActivity : (activity) =>
      view = new ActivityView(model: activity, onProfile: false)
      @$activity.append view.render().el
      
    addAllActivity: (collection, filter) =>

      @$activity.html ""

      visible = @model.activity.select (a) => a.get("property") and a.get("property").id is @model.id
      if visible.length > 0 then _.each visible, @addOneActivity
      else @$activity.html '<li class="empty">' + i18nProperty.tenant_empty.activity + '</li>'

    # Photos
    # ------

    addOnePhoto : (photo) =>
      view = new PhotoView(model: photo)
      @$photos.append view.render().el
      
    addAllPhotos: (collection, filter) =>

      $('#photos-link .count').html @model.photos.length

      @$photos.html ""
      unless @model.photos.length is 0
        @model.photos.each @addOnePhoto
      else
        @$photos.html '<li class="empty offset2 span4">' + i18nProperty.tenant_empty.photos + '</li>'

    # Listings
    # --------

    addOneListing : (listing) =>
      @$listings.append new ListingView(model: listing).render().el
      
    addAllListings: (collection, filter) =>

      @$listings.html ""

      visible = @model.listings.select (a) => a.get("property").id is @model.id
      $('#listings-link .count').html visible.length

      if visible.length > 0 

        # Get listings with unknown # of bedrooms.
        listings = _.filter visible, (l) -> l.get("bedrooms") is undefined
        if listings.length > 0
          @$listings.append "<tr class='divider'><td colspan='4'>#{i18nUnit.fields.bedrooms}: #{i18nCommon.adjectives.not_specified}</td></tr>"
          _.each listings, @addOneListing

        # Get listings where we have a # of bedooms.
        for i in [0..6]
          listings = _.filter visible, (l) -> l.get("bedrooms") is i
          if listings.length > 0
            @$listings.append '<tr class="divider"><td colspan="4">' + i18nUnit.fields.bedrooms + ": #{i}</td></tr>"
            _.each listings, @addOneListing
      else
        @$listings.html "<tr class='empty'><td colspan='4'>#{i18nProperty.tenant_empty.listings}</td></tr>"

    # Lease Modal
    # -----------

    showLeaseModal: (e) =>
      e.preventDefault()
      if Parse.User.current()
        require ['models/Lease', 'views/lease/New'], (Lease, NewLeaseView) =>
          @lease = new Lease property: @model, forNetwork: false unless @lease
          new NewLeaseView(model: @lease, property: @model, network: @model.get("network"), modal: true).render().$el.modal()
      else
        $("#signup-modal").modal()

    undelegateEvents : =>
      @detachModalEvents() if @modal
      super


    # Modal
    # @see profile:show and property:public
    # --------------------------------------------

    showModal : (e) =>
      e.preventDefault()
      @modal = true
      @index = 0
      @collection = @model.activity.select((a) => a.get("property") and a.get("property").id is @model.id)
      # Find the model in the collection, while simultaneously recording the index of our new array.
      data = $(e.currentTarget).data()
      model = _.find @collection, (f) => @index++; f.id is data.id
      # Correct for auto-increment
      @index -= 1
      @renderModalContent model
      $("#view-content-modal").modal(keyboard: false)
      
      # Add events.
      $(document).on "keydown", @controlModalIfOpen
      $('#view-content-modal').on 'click', '.caption a', @closeModal
      $('#view-content-modal').on 'click', '.left', @prevModal
      $('#view-content-modal').on 'click', '.right', @nextModal
      $('#view-content-modal').on 'hide.bs.modal', @hideModal
      $('#view-content-modal').on 'click', '.like-button', @likeOrLogin
      $('#view-content-modal').on 'click', '.likers', @showLikers
      $('#view-content-modal').on 'submit', 'form', @postComment

    controlModalIfOpen : (e) =>
      return unless @modal
      switch e.which 
        when 27 then $("#view-content-modal").modal('hide')
        when 37 then @prevModal()
        when 39 then @nextModal()

    closeModal : =>
      $("#view-content-modal").modal('hide')

    hideModal : =>
      return unless @modal
      @modal = false

      @detachModalEvents()

    detachModalEvents : ->
      $(document).off "keydown"
      $('#view-content-modal').off "hide click"
      # $('#view-content-modal .caption a').off 'click'
      # $('#view-content-modal .left').off 'click'
      # $('#view-content-modal .right').off 'click'

    nextModal : =>
      return unless @modal
      @index++
      if @index >= @collection.length then @index = 0
      @renderModalContent @collection[@index]

    prevModal : =>
      return unless @modal
      @index--
      if @index < 0 then @index = @collection.length - 1
      @renderModalContent @collection[@index]

    renderModalContent : (model) =>

      # Add a building link if applicable.
      # Cache result
      property = if model.get("property") and not model.linkedToProperty() then model.get("property") else false

      vars = _.merge model.toJSON(), 
        url: model.url()
        start: moment(model.get("startDate")).format("LLL")
        end: moment(model.get("endDate")).format("LLL")
        postDate: moment(model.createdAt).fromNow()
        liked: model.liked()
        postImage: model.image("large")
        icon: model.icon()
        name: model.name()
        profileUrl: model.profileUrl()
        profilePic: model.profilePic("thumb")
        propertyLinked: if property then true else false
        propertyTitle: if property then property.get("title") else false
        propertyCover: if property then property.cover("tiny") else false
        propertyUrl: if property then property.publicUrl() else false
        current: Parse.User.current()
        i18nCommon: i18nCommon

      if Parse.User.current()
        vars.self = Parse.User.current().get("profile").name()
        vars.selfProfilePic = Parse.User.current().get("profile").cover("tiny")

      # Default options. 
      _.defaults vars,
        rent: false
        image: false
        isEvent: false
        endDate: false
        likeCount: 0
        commentCount: 0

      # Override default title.
      vars.title = model.title()

      $("#view-content-modal").html JST["src/js/templates/activity/modal.jst"](vars)

      # Comments
      @$comments = $("#view-content-modal .list-comments")
      @$comments.html ""
      visible = model.comments.select (c) => c.get("activity") and c.get("activity").id is model.id
      if visible.length > 0 then _.each visible, @renderOneModalComment

    renderOneModalComment : (comment) =>

      vars =
        title: comment.get "title"
        postDate: moment(comment.createdAt).fromNow()
        name: comment.name()
        profilePic: comment.profilePic("tiny")
        profileUrl: comment.profileUrl()
        i18nCommon: i18nCommon

      # fn = if isNew then "append" else "prepend"

      @$comments.append JST["src/js/templates/comment/summary.jst"](vars)