define [
  "jquery"
], ($) ->

  $.fn.toggler = ->
    
    @radio = @find "input"
    @radio.eq(0).on 'click', => @toggleClass "toggle-off"
    @radio.eq(1).on 'click', => @toggleClass "toggle-off"
    
    if @radio.eq(0).is(":checked")
      @removeClass "toggle-off"
    else
      @addClass "toggle-off"
      
    @

