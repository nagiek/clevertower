define [
  "jquery"
  "underscore"
  "backbone"
  "collections/ContactList"
  "views/helper/Contact"
  "i18n!nls/common"
  "templates/helper/select_email"
], ($, _, Parse, ContactList, ContactView, i18nCommon) ->

  class SelectEmailView extends Parse.View
    
    # id: 'select-email-modal'
    className: 'modal modal-form fade hide'

    events:
      "click .done" : 'close'
      "click .next" : 'next'
      "click .prev" : 'prev'
    
    initialize: (attrs) ->

      @view = attrs.view
      @contacts = new ContactList
      @listenTo @contacts, "add", @addOne
      @listenTo @contacts, "reset", @addAll

      @index = 1
      @authUrl = """
          https://accounts.google.com/o/oauth2/auth?
          response_type=token&
          client_id=#{window.GCLIENT_ID}&
          scope=
            https://www.googleapis.com/auth/userinfo.email%20
            https://www.googleapis.com/auth/userinfo.profile%20
            https://www.google.com/m8/feeds&
          state=#{window.location.pathname}&
          redirect_uri=http://localhost:3000/oauth2callback
          """

      # Log in to Google to before getting the contacts
      if !Parse.User.current().get("googleAuthData") or new Date().getTime() / 1000 > Parse.User.current().get("googleAuthData").expires_in
        window.location.replace @authUrl
      # Get the contacts
      else @query()

    query : => 
      $.ajax """
          https://www.google.com/m8/feeds/contacts/default/full/?alt=json&start-index=#{@index}&max-results=100&
          access_token=#{Parse.User.current().get("googleAuthData").access_token}
          """,
          # access_token=ya29.AHES6ZQIyc9B_jG5ktMrRMjj7qFJvtWNJRuPw-kwdvRM2_12wclq1w
          # access_token=#{Parse.User.current().get("googleAuthData").access_token},
          # Include a blank beforeSend to override the default headers.
          beforeSend: (jqXHR, settings) ->
            # jqXHR.setRequestHeader "Authorization", "Bearer " + "ya29.AHES6ZTGcD5Q6WpPffEc3YgtywLHog13PoAyvhMBeCBEMKs" # + Parse.User.current().get("googleAuthData").access_token
            # jqXHR.setRequestHeader "GData-Version", "3.0"
          success: @addAll
          error: -> 
            window.location.replace @authUrl

        # gapi.client.request
        #   path: "/m8/feeds/contacts/default/full"
        #   headers: 
        #     # Authorization: "Bearer ya29.AHES6ZTxc75Uuj4kWLdAJ1aQ-gP2Z4BUklJUlhAE4XBBqG8" # + Parse.User.current().get("googleAuthData").access_token
        #     # Authorization: "ya29.AHES6ZTxc75Uuj4kWLdAJ1aQ-gP2Z4BUklJUlhAE4XBBqG8" # + Parse.User.current().get("googleAuthData").access_token
        #     "GData-Version": "3.0"
        #   params:
        #     alt: "json"
        #     access_token: "ya29.AHES6ZTxc75Uuj4kWLdAJ1aQ-gP2Z4BUklJUlhAE4XBBqG8" # + Parse.User.current().get("googleAuthData").access_token
        #   callback: (resp) =>
        #     console.log resp
        #     if resp and !resp.error
        #       $('body').append new SelectEmail(view: @).render().el

    # Re-render the contents of the Unit item.
    render: ->
      @$el.html JST["src/js/templates/helper/select_email.jst"](i18nCommon: i18nCommon)
      $("body").append @el
      @$list = @$(".modal-body table tbody")
      @$start = @$(".modal-header .start")
      @$end = @$(".modal-header .end")
      @$el.modal()
      @

    prev: => 
      @index -= 100
      if @index is 1 then @$('.prev').prop "disabled", true
      @query()
    next: ->
      @index += 100
      @query()
      @$('.prev').prop "disabled", false

    addOne: (c) =>
      @$list.append new ContactView(modal: @, view: @view, model: c).render().el

    addAll: (res) =>
      models = _.map res.feed.entry, (e) -> 
        email = _.reject(e.gd$email, (email) -> email.primary is false)[0]
        if email
          new Parse.Object
            name: e.title.$t
            email: email.address
      @$list.html ""
      @$start.html @index
      @$end.html @index + res.feed.entry.length
      @contacts.add models

    close: (e) =>
      # e.preventDefault()
      @trigger('close')
      @$el.modal('hide')
      @remove()
      @undelegateEvents()
      delete this