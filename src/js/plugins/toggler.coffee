define [
  "jquery"
], ($) ->

  $.fn.toggler = ->
    
    toggleOn = => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(1).prop "checked", "checked"
      console.log "toggle:on"
      @trigger "toggle:on"

    toggleOff = => 
      @toggleClass "toggle-off"
      @removeProp "checked"
      @radio.eq(0).prop "checked", "checked"
      console.log "toggle:off"
      @trigger "toggle:off"

    @radio = @find "input"
    @radio.eq(0).on 'click', toggleOn
    @radio.eq(1).on 'click', toggleOff
    
    if @radio.eq(0).is(":checked")
      @removeClass "toggle-off"
    else
      @addClass "toggle-off"
      
    @

