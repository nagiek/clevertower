define [
  "jquery"
  "underscore"
  "backbone"
  'models/Photo'
  'views/activity/MidNew'
  'views/user/AppsModal'
  "i18n!nls/property"
  "i18n!nls/common"
  "plugins/toggler"
  'templates/property/new/share'
], ($, _, Parse, Photo, MidNewActivityView, AppsModalView, i18nProperty, i18nCommon) ->

  # GMapView
  # anytime the points change or the center changes
  # we update the model two way <-->
  class ShareModalPropertyView extends MidNewActivityView

    className: "modal hide fade in"

    events:
      "submit form"                     : "save"
      "change #toggle-end-date"         : "toggleEndDate"
      "click #add-property"             : "toggleBuildingActivity"
      "click #add-time"                 : "toggleTime"
      "click .photo-destroy"            : "unsetImage"
      # Share options
      "change #post-as-property"        : "togglePostAsProperty"
      "change #post-private"            : "togglePostPrivate"
      # Choose image.
      "click .prev"                     : "prev"
      "click .next"                     : "next"
      "click .save"                     : "save"
      "close"                           : "clear"
      # Share options
      "change #fbShare"                 : "checkShareOnFacebook"
        
    initialize: (attrs) ->
      @index = 0
      @property = attrs.property
      @property.prep "photos"
      if @property.photos.length is 0 then @model.photos.add new Photo(image: @property.cover("large"))

    render : ->

      vars = 
        title: i18nProperty.activity.new_property @model.get("title")
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon

      @$el.html JST["src/js/templates/property/share_modal.jst"](vars)
      @$list = @$(".photo")
      @$('.toggle').toggler()
      @addAll()
      @

    prev: => 
      @index--
      @$list.children().addClass("hide")
      @$list.find(":nth-child(#{@index})").removeClass("hide")
    next: =>
      @index++
      @$list.children().addClass("hide")
      @$list.find(":nth-child(#{@index})").removeClass("hide")

    addOne : (photo, i) =>
      klass = if i > 0 then 'class="hide" ' else ""
      @$list.append "<img #{klass}src='#{photo.get("image")}''>"
      
    # Add all items in the Properties collection at once.
    addAll: (collection, filter) =>
      if @property.photos.length is 1
        @$(".prev").addClass("hide")
        @$(".next").addClass("hide")
      @model.photos.each @addOne

    save : (e) ->
      e.preventDefault() if e

      @model.set("image", @property.photos.get(@index).get("image"))

      @$('button.save').prop "disabled", true
      data = @$('form').serializeObject()
      @$('.error').removeClass('error')

      return @model.trigger "invalid", error: message: i18nCommon.errors.no_data unless data.activity.title or @model.get("image")

      attrs = 
        title: data.activity.title

      if @model.get("isEvent")
        
        return @model.trigger "invalid", error: message: i18nCommon.errors.no_start_date unless data.activity.start_date
        attrs.startDate = new Date("#{data.activity.start_date} #{data.activity.start_time}")
        if @$('#toggle-end-date').is ":checked"
          return @model.trigger "invalid", error: message: i18nCommon.errors.no_end_date unless data.activity.end_date
          attrs.endDate = new Date("#{data.activity.end_date} #{data.activity.end_time}") if data.activity.end_date

      @model.save(attrs).then (model) => 
        # Add to appropriate collection
        # if @model.get("property")
        Parse.User.current().activity.add @model, silent: true if Parse.User.current().activity
        # else Parse.App.activity.add @model, silent: true if Parse.App.activity

        # Share on FB?
        if data.share.fb is "on" or data.share.fb is "1"
          window.FB.api "/me/clevertower:post",
            # object_type: "clevertower:post"
            message: @model.get("title")
            start_time: @model.get("start_date")
            end_time: @model.get("end_date")
            image: @model.get("image")

        @$el.modal("close")
      , (error) => console.log error
