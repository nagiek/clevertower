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
      'click .close' : 'delete'
    
    initialize: (attrs) ->

      @container = $('#messages')

      @fade   = if attrs.fade?  then attrs.fade   else false
      @event  = if attrs.event? then attrs.event  else ''

      # Could have done this with underscore but ah well.
      @vars = attrs
      @vars.type = 'success'  unless attrs.type?
      @vars.dismiss = true    unless attrs.dismiss?
      @vars.heading = ''      unless attrs.heading?
      @vars.message = ''      unless attrs.message?
      @vars.buttons = ''      unless attrs.buttons?
      @vars.event = @event

      @render()

    # Re-render the contents of the Unit item.
    render: ->
      
      if @event isnt '' and @container.find("#alert-#{@event}").length is 0
        alert = @container.append JST['src/js/templates/helper/alert.jst'](@vars)
        alert.delay(3000).fadeOut() if @fade
      
    delete: ->
      delete this