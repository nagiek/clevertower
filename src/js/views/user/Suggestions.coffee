define [
  "jquery"
  "underscore"
  "backbone"
  "collections/ProfileList"
  "views/helper/Alert"
  "views/profile/suggestion"
  "views/user/sub/apps/facebook"
  "i18n!nls/common"
  "i18n!nls/user"
  "templates/user/suggestions"
], ($, _, Parse, ProfileList, Alert, ProfileSuggestionView, FacebookAppView, i18nCommon, i18nUser) ->

  class SuggestionsUserView extends Parse.View
    
    el: '#main'
    
    events:
      'click .nav a' : 'changeSubView'
      'click .import-from-google' : 'importFromGoogle'

    initialize : (attrs) ->

      @emails = []

      unless Parse.User.current().recommendedSuggestions and Parse.User.current().emailSuggestions and Parse.User.current().facebookSuggestions
        Parse.User.current().recommendedSuggestions = new ProfileList [], {}
        Parse.User.current().emailSuggestions = new ProfileList [], {}
        Parse.User.current().facebookSuggestions = new ProfileList [], {}

        Parse.User.current().recommendedSuggestions.query.equalTo "recommended", true,
        Parse.User.current().facebookSuggestions.query.containedIn "fbID", Parse.User.current().get("fbFriends")
      
      @query = Parse.Query.or(Parse.User.current().recommendedSuggestions.query,
        Parse.User.current().emailSuggestions.query,
        Parse.User.current().facebookSuggestions.query
      ).include("property").include("location")

      @listenTo Parse.User.current().recommendedSuggestions,  "add", @addOneRecommended
      @listenTo Parse.User.current().emailSuggestions,        "add", @addOneEmail
      @listenTo Parse.User.current().facebookSuggestions,     "add", @addOneFacebook

      # If user connects to Facebook, find facebook friends
      @listenTo Parse.User.current(), "change:fbFriends", =>
        Parse.User.current().facebookSuggestions.query.containedIn "fbID", Parse.User.current().get("fbFriends")
        Parse.User.current().facebookSuggestions.query.find().then @addToCollection


      @listenTo Parse.Dispatcher, "user:logout", -> Parse.history.navigate("/", true)

    
    clear: =>
      @undelegateEvents()
      @stopListening()
      delete this

    undelegateEvents : =>

      super

      $(window).off "scroll"
      $(document.documentElement).off "scroll"

    render: =>

      vars =
        i18nCommon: i18nCommon
        i18nUser: i18nUser
        isFollowing: Parse.User.current().get("profile").get("followingCount") > 0
      @$el.html JST["src/js/templates/user/suggestions.jst"](vars)

      @$(".facebook-group").html new FacebookAppView().render().el # unless Parse.User.current()._isLinked("facebook")
        
      @$recommendedList = @$("#recommended ul.content")
      @$facebookList = @$("#by-facebook ul.content")
      @$emailList = @$("#by-email ul.content")

      @$loading = @$(".loading")

      $(window).scroll @loadTracker
      $(document.documentElement).scroll @loadTracker

      # Add existing objs in the collection.
      Parse.User.current().recommendedSuggestions.each @addOneRecommended
      Parse.User.current().emailSuggestions.each @addOneEmail
      Parse.User.current().facebookSuggestions.each @addOneFacebook

      @query.find().then @addToCollection

      # Start process with default tab.
      e = currentTarget: hash: "#recommended"
      @changeSubView e
        
      @

    changeSubView: (e) ->

      @$loading.html """<img src='/img/misc/spinner.gif' class='spinner' alt="#{i18nCommon.verbs.loading}" />"""

      switch e.currentTarget.hash
        when "#recommended"
          if Parse.User.current().recommendedSuggestions.length is 0
            @$loading.empty()
            @$recommendedList.html "<p class='col-xs-12 center empty'>empty</p>"
          else if @recommendedCount
            @moreToDisplay = if @recommendedCount > Parse.User.current().recommendedSuggestions.length then true else false
          else
            Parse.User.current().recommendedSuggestions.query.count().then (count) => 
              @recommendedCount = count
              # Walk through again
              @changeSubView(e)
        when "#by-email"
          if Parse.User.current().emailSuggestions.length is 0
            @$loading.empty()
            @$emailList.html "<p class='col-xs-12 center empty'>empty</p>"
          else if @emailCount
            @moreToDisplay = if @emailCount > Parse.User.current().emailSuggestions.length then true else false
          else
            Parse.User.current().emailSuggestions.query.count().then (count) => 
              @emailCount = count
              # Walk through again
              @changeSubView(e)
        when "#by-facebook"
          if Parse.User.current().facebookSuggestions.length is 0
            @$loading.empty()
            @$facebookList.html "<p class='col-xs-12 center empty'>empty</p>"
          else if @facebookCount 
            @moreToDisplay = if @facebookCount > Parse.User.current().facebookSuggestions.length then true else false
          else
            Parse.User.current().facebookSuggestions.query.count().then (count) => 
              @facebookCount = count
              # Walk through again
              @changeSubView(e)

      @$loading.empty() unless @moreToDisplay


    # Google
    # -------

    importFromGoogle: (e) =>
      e.preventDefault()

      @authUrl = """
          https://accounts.google.com/o/oauth2/auth?
          response_type=token&
          client_id=#{window.GCLIENT_ID}&
          scope=
            https://www.googleapis.com/auth/userinfo.email%20
            https://www.googleapis.com/auth/userinfo.profile%20
            https://www.google.com/m8/feeds&
          state=#{window.location.pathname}&
          redirect_uri=http://clevertower.dev:3000/oauth2callback
          """

      # Log in to Google to before getting the contacts
      if !Parse.User.current().get("googleAuthData") or new Date().getTime() / 1000 > Parse.User.current().get("googleAuthData").expires_in
        window.location.replace @authUrl
      # Get the contacts
      else @queryGoogle()

    queryGoogle : => 
      $.ajax """
          https://www.google.com/m8/feeds/contacts/default/full/?alt=json&start-index=0&max-results=1000&
          access_token=#{Parse.User.current().get("googleAuthData").access_token}
          """,
          # Include a blank beforeSend to override the default headers.
          beforeSend: (jqXHR, settings) ->
          success: @addGoogleAddresses
          error: -> 
            window.location.replace @authUrl

    addGoogleAddresses : ->
      models = _.map res.feed.entry, (e) => 
        email = _.reject(e.gd$email, (email) -> email.primary is false)[0]
        @emails.push email.address if email

      Parse.User.current().emailSuggestions.query.containedIn "email", @emails
      Parse.User.current().emailSuggestions.query.find().then @addToCollection

    # Loading
    # -------

    endOfDocument: =>
      viewportBottom = $(window).scrollTop() + $(window).height()
      @$loading.offset().top <= viewportBottom

    loadTracker: =>
      console.log "loadTracker"
      if(!@updateScheduled and @moreToDisplay)
        setTimeout =>
          if @endOfDocument() then @nextPage()
          @updateScheduled = false
        , 2000
        @updateScheduled = true

    nextPage: ->
      console.log @$("ul.nav > li.active > a")
      console.log @$("ul.nav > li.active > a").attr("href")
      switch @$("ul.nav > li.active > a").attr("href")
        when "#recommended"  then Parse.User.current().recommendedSuggestions.query.find().then @addToCollection
        when "#by-email"     then Parse.User.current().emailSuggestions.query.find().then @addToCollection
        when "#by-facebook"  then Parse.User.current().facebookSuggestions.query.find().then @addToCollection


    # Adding
    # ------

    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOneRecommended: (p) =>
      view = new ProfileSuggestionView(model: p)
      @$recommendedList.append view.render().el

    addOneEmail: (p) =>
      view = new ProfileSuggestionView(model: p)
      @$emailList.append view.render().el

    addOneFacebook: (p) =>
      view = new ProfileSuggestionView(model: p)
      @$facebookList.append view.render().el

    addToCollection: (objs) =>
      hadRecommended = false
      hadEmail = false
      hadFacebook = false
      if objs
        for obj in objs
          if obj.get("recommended")
            Parse.User.current().recommendedSuggestions.add obj
            hadRecommended = true
          else if _.contains @emails, obj.get("email")
            Parse.User.current().emailSuggestions.add obj
            hadEmail = true
          else if _.contains Parse.User.current().get("fbFriends"), obj.get("fbID")
            Parse.User.current().facebookSuggestions.add obj
            hadFacebook = true

        if hadRecommended then @$recommendedList.find(".empty").remove()
        if hadEmail then @$facebookList.find(".empty").remove()
        if hadFacebook then @$emailList.find(".empty").remove()
