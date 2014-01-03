define [
  "jquery"
  "underscore"
  "backbone"
  "i18n!nls/common"
  'templates/location/summary'
], ($, _, Parse, i18nCommon) ->

  class SummaryLocationView extends Parse.View
  
    el: "#city"

    events:
      'click .follow' : 'follow'
      'click .close' : 'clear'
    
    initialize : (attrs) ->

      @view = attrs.view
  
    # Re-render the contents of the property item.
    render: ->

      # Find if we have a connection to the person.
      vars =
        bio: @model.get("profile").get("bio")
        name: @model.get("profile").name()
        image: @model.get("profile").cover("full")
        followedByUser: @model.get("profile").followedByUser()
        i18nCommon: i18nCommon

      # FB Meta Tags
      $("head meta[property='og:description']").attr "content", vars.bio
      $("head meta[property='og:url']").attr "content", window.location.href
      $("head meta[property='og:image']").attr "content", window.location.origin + vars.image
      $("head meta[property='og:type']").attr "content", "clevertower:city"
      
      @$el.html JST["src/js/templates/location/summary.jst"](vars)

      @


    # Copied from BaseIndexActivityView
    follow : (e, buttonParent, undo) =>

      buttonParent = buttonParent || @$(e.currentTarget).parent()

      if @model.get("profile").followedByUser()
        buttonParent.html """<button type="button" class="btn btn-primary follow">#{i18nCommon.actions.follow}</button>"""

        Parse.User.current().get("profile").increment followingCount: -1
        Parse.User.current().get("profile").relation("following").remove @model.get("profile")
        Parse.User.current().get("profile").following.remove @model.get("profile")

        # Check through other subviews to 
        @view.trigger "profile:unfollow", @model.get("profile")

        unless undo
          Parse.Cloud.run "Unfollow", {
            followee: @model.get("profile").id
            follower: Parse.User.current().get("profile").id
          },
          # Optimistic saving.
          # success: (res) => 
          error: (res) => 
            # Undo what we did.
            @follow(e, buttonParent, true)
            console.log res
        else new Alert event: 'follow', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'

      else
        # extra span to break up .btn + .btn spacing
        # Don't put in the unfollow button right away.
        buttonParent.html("""<span class="btn btn-primary following">#{i18nCommon.verbs.following}</span>""")
        setTimeout ->
          buttonParent.append """
            <span></span> 
            <button type="button" class="btn btn-default follow unfollow">#{i18nCommon.actions.unfollow}</button>
          """
        , 500

        Parse.User.current().get("profile").increment followingCount: +1
        Parse.User.current().get("profile").relation("following").add @model.get("profile")
        # Adding to a relation will somehow add to collection..?
        Parse.User.current().get("profile").following.add @model.get("profile")

        @view.trigger "profile:follow", @model.get("profile")

        unless undo
          Parse.Cloud.run "Follow", {
            followee: @model.get("profile").id
            follower: Parse.User.current().get("profile").id
          },
          # Optimistic saving.
          # success: (res) => 
          error: (res) => 
            # Undo what we did.
            @follow(e, buttonParent, true)
            console.log res
        else new Alert event: 'follow', fade: false, message: i18nCommon.errors.not_saved, type: 'danger'
        
      Parse.User.current().get("profile").save()

    clear: =>
      @remove()
      @undelegateEvents()
      delete this
      