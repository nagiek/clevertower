define [
  "jquery"
], ($) ->

  $.fn.toggler = ->
    
    toggleOn = => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(0).prop "checked", "checked"
      @trigger "toggle:on"

    toggleOff = => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(1).prop "checked", "checked"
      @trigger "toggle:off"

    @radio = @find "input"
    @radio.eq(0).on 'click', toggleOff
    @radio.eq(1).on 'click', toggleOn
    
    if @radio.eq(0).is(":checked")
      @removeClass "toggle-off"
    else
      @addClass "toggle-off"
      
    @

