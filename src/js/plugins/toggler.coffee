define [
  "jquery"
], ($) ->

  $.fn.toggler = ->
    
    @radio = @find "input"
    @radio.eq(0).on 'click', => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(1).prop "checked", "checked"
      
    @radio.eq(1).on 'click', => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(0).prop "checked", "checked"
    
    if @radio.eq(0).is(":checked")
      @removeClass "toggle-off"
    else
      @addClass "toggle-off"
      
    @

