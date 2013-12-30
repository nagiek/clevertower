define [
  "jquery"
  "underscore"
  "backbone"
  'models/Lease'
  'models/Profile'
  "views/helper/Alert"
  "i18n!nls/common"
  'templates/profile/summary'
], ($, _, Parse, Lease, Profile, Alert, i18nCommon) ->

  class ProfileSummaryView extends Parse.View
  
    tagName: "li"
    className: "clearfix"
    
    events:
      'click .follow' : 'follow'
    
    initialize : (attrs) ->

      @view = attrs.view

      if Parse.User.current() and @model.get("unit")
        if Parse.User.current().get("network")
          @listenTo Parse.User.current().get("network").units, "reset", @addUnit
        else if Parse.User.current().get("property")
          @listenTo Parse.User.current().get("property").units, "reset", @addUnit
  
    # Re-render the contents of the property item.
    render: ->
      vars =
        url: @model.url()
        cover: @model.cover("thumb")
        followedByUser: @model.followedByUser()
        name: @model.name()
        i18nCommon: i18nCommon
        # To be overridden
        property: false
        unit: false

      # Find if we have a connection to the person.
      if Parse.User.current()
        if Parse.User.current().get("network")
          if @model.get("property")
            property = Parse.User.current().get("network").properties.find((p) => p.id is @model.get("property").id)
            if property 
              vars.property = property.get("title")
              # If we have the property, check for the unit.
              if @model.get("unit")
                unit = Parse.User.current().get("network").units.find((u) => u.id is @model.get("unit").id)
                if unit then vars.unit = unit.get("title")
        if Parse.User.current().get("property")
          if @model.get("property")
            if Parse.User.current().get("property") and Parse.User.current().get("property").id is @model.get("property").id 
              vars.property = Parse.User.current().get("property").get("title")

              # If we have the property, check for the unit.
              if @model.get("unit")
                unit = Parse.User.current().get("property").units.find((u) => u.id is @model.get("unit").id)
                if unit then vars.unit = unit.get("title")

      @$el.html JST["src/js/templates/profile/summary.jst"](vars)
      @

    # Units may not be queried yet. Stand by to add.
    addUnit: ->
      if Parse.User.current()
        if Parse.User.current().get("network")
          unit = Parse.User.current().get("network").units.find((u) => u.id is @model.get("unit").id)
        else if Parse.User.current().get("property")
          unit = Parse.User.current().get("property").units.find((u) => u.id is @model.get("unit").id)
          
        if unit then @$(".unit > small").html unit.get("title")

    # Copied from BaseIndexActivityView
    follow : (e, buttonParent, undo) =>

      buttonParent = buttonParent || @$(e.currentTarget).parent()

      if @model.followedByUser()
        buttonParent.html """<button type="button" class="btn btn-primary follow">#{i18nCommon.actions.follow}</button>"""

        Parse.User.current().get("profile").increment followingCount: -1
        Parse.User.current().get("profile").relation("following").remove @model
        Parse.User.current().get("profile").following.remove @model

        # Check through other subviews to 
        @view.trigger "profile:unfollow", @model

        unless undo
          Parse.Cloud.run "Unfollow", {
            followee: @model.id
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
        Parse.User.current().get("profile").relation("following").add @model
        # Adding to a relation will somehow add to collection..?
        Parse.User.current().get("profile").following.add @model

        @view.trigger "profile:follow", @model

        unless undo
          Parse.Cloud.run "Follow", {
            followee: @model.id
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
      