define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/property"
  "gmaps"
], ($, _, Parse, i18nProperty) ->

  class PromptPropertyView extends Parse.View

    el: '#property-prompt'

    initialize: (attrs) ->

      @listenTo Parse.Dispatcher, "user:logout", @clear
      @render() unless Parse.User.current().get("property") or Parse.User.current().get("network")

    render: ->

      @$el.html """
                <div class="well">
                  <p>CleverTower is more fun when you're connected, but you haven't joined a property yet.</p>
                  <a href="/account/setup" class="btn btn-primary">Get Started</a>
                </div>
                """
      @

    clear: ->
      @$el.empty()
      @stopListening()
      @undelegateEvents()
      delete this