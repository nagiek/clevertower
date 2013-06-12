define [
  "jquery"
  "underscore"
  "backbone"
  "templates/helper/alert"
], ($, _, Parse) ->

  class AlertView extends Parse.View
    
    tagName: 'div'
    className: 'alert'
    
    events:
      'click .close' : 'clear'
    
    initialize: (attrs) ->

      @container = $('#messages')

      @fade   = if attrs.fade  then attrs.fade   else false

      # Could have done this with underscore but ah well.
      @vars = attrs
      @vars.type = 'success'  unless attrs.type
      @vars.dismiss = true    unless attrs.dismiss
      @vars.heading = ''      unless attrs.heading
      @vars.message = ''      unless attrs.message
      @vars.buttons = ''      unless attrs.buttons
      @vars.event = ''        unless attrs.event

      @render()

    # Re-render the contents of the Unit item.
    render: ->
      
      return unless @vars.event

      alert = @container.find("#alert-#{@event}")
      if alert.length is 0
        alert = @container.append JST['src/js/templates/helper/alert.jst'](@vars)
        alert.delay(3000).fadeOut() 
      else
        alert.removeClass "alert-"
        alert.addClass "alert-#{@vars.type}"
        alert.find(".message").html @vars.message

      
    clear: ->
      @$el.removeClass "in"
      setTimeout 150, =>
        @remove()
        @undelegateEvents()
        delete this

    setError: (msg) ->
      @vars.message = msg
      @vars.type = 'error'
      @render()