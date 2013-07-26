define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "models/Search"
  "i18n!nls/common"
  'templates/helper/search'
  'gmaps'
], ($, _, Parse, Property, Search, i18nCommon) ->

  class SearchView extends Parse.View
    
    el: '#search-menu'
    
    events:
      'submit form': 'doNothing'

    initialize : ->

      @autoService = new google.maps.places.AutocompleteService()

      @on "google:search", (data) => 
        # Store last ref in case we have to come and get it.
        @lastReference = data.reference

        # Send our user to the right page. 
        # If we are already on a Search page, view will not be re-init'ed.
        Parse.history.navigate "/outside/#{data.location}", trigger: true 
        new Search(reference: data.reference, location: data.location).save()

      @listenTo Parse.Dispatcher, "user:change", @reset

      @initDatasets()


    initDatasets: ->
      @vars = [
        name: 'properties'
        header: "<span class='nav-header'>#{i18nCommon.classes.Properties}</span>"
        remote:
          url: "https://api.parse.com/1/classes/Property"
          replace: (url, uriEncodedQuery) ->
            # /^      Begin 
            # .*      Any length of characters
            # \Q      Treat characters as literals 
            # REGEX   Starts with our query .
            # \E      Stop special character treatment
            # .*      Any length of characters
            # $/      End 
            # i       Case insensitive 
            url += "?where=" + encodeURIComponent(JSON.stringify({title:{$regex:"REGEX"}}))
            # r = url.replace "REGEX", encodeURIComponent("/^\\Q") + uriEncodedQuery + encodeURIComponent("\\E.*$/i")
            r = url.replace "REGEX", encodeURIComponent("^.*") + uriEncodedQuery + encodeURIComponent(".*$")
            r
          filter: (parsedResponse) ->
            return [] if parsedResponse.results.length is 0
            _.map parsedResponse.results, (p) ->

              url = if Parse.User.current() and Parse.User.current().get("network") and Parse.User.current().get("network").properties.get p.objectId
                Property.url(p.objectId)
              else 
                Property.publicUrl Property.country(p.country), p.administrative_area_level_1, p.locality, p.objectId, Property.slug(p.title)

              value: p.title
              img_src: if p.image_tiny then p.image_tiny else "/img/fallback/property-tiny.png"
              url: url
              tokens: _.union(p.title.split(" "), p.thoroughfare.split(" "), [p.locality])
        limit: 5
        template: _.template  """
                              <% if (value) { %>
                              <a href="<%= url %>">
                                <img src="<%= img_src %>" class="photo-tiny" width="32" height="32">
                                <strong><%= value %></strong>
                              </a>
                              <% } %>
                              """
      ,
        name: 'people'
        header: "<span class='nav-header'>#{i18nCommon.nouns.People}</span>"
        remote:
          url: "https://api.parse.com/1/classes/Profile"
          replace: (url, uriEncodedQuery) ->
            # /^      Begin 
            # .*      Any length of characters
            # \Q      Treat characters as literals 
            # REGEX   Starts with our query .
            # \E      Stop special character treatment
            # .*      Any length of characters
            # $/      End 
            # i       Case insensitive 
            url += "?where=" + encodeURIComponent(JSON.stringify({first_name:{$regex:"REGEX"}}))
            # r = url.replace "REGEX", encodeURIComponent("/^\\Q") + uriEncodedQuery + encodeURIComponent("\\E.*$/i")
            r = url.replace "REGEX", encodeURIComponent("^.*") + uriEncodedQuery + encodeURIComponent(".*$")
            r
          filter: (parsedResponse) ->
            return [] if parsedResponse.results.length is 0
            _.map parsedResponse.results, (p) ->
              value: p.name()
              img_src: p.cover("tiny")
              url: p.url()
        limit: 5
        template: _.template  """
                              <% if (value) { %>
                              <a href="<%= url %>">
                                <img src="<%= img_src %>" class="photo-tiny" width="32" height="32">
                                <strong><%= value %></strong>
                              </a>
                              <% } %>
                              """
      ,
        name: 'places'
        header: "<span class='nav-header'>#{i18nCommon.nouns.places}</span>"
        footer: """
                <span class='nav-header'>
                  <img src='https://maps.gstatic.com/mapfiles/powered-by-google-on-white.png' alt='Powered by Google'>
                </span>
                """
        computed: (q, done) => 
          @autoService.getPlacePredictions {input: q, types: ['geocode']}, (predictions, status) -> 
            predictions ||= []
            _.each predictions, (p) ->
              p.url = _.map(p.terms, (t) -> t.value).join("--").replace(" ", "-")
              p.value = p.description

            done(predictions, status)
        limit: 5
        template: _.template  """
                              <% if (value) { %>
                              <a href="/outside/<%= url %>" data-reference="<%= reference %>" class="google">
                                <strong><%= value %></strong>
                              </a>
                              <% } %>
                              """

      
        # XML HTTP Request code
        # name: 'places'
        # header: "<span class='nav-header'>#{i18nCommon.nouns.Places}</span>"

        # remote:
        #   method: "GET"
        #   dataType: 'jsonp'
        #   url: "https://maps.googleapis.com/maps/api/place/autocomplete/json" +   # Return JSON format
        #         "?input=%QUERY" +                                                 # Autocomplete
        #         "&types=geocode" +                                                # Places only
        #         "&key=#{window.GMAPS_KEY}" +                                      # Key
        #         "&sensor=false"                                                   # No Geocode
        #   filter: (parsedResponse) -> console.log parsedResponse; parsedResponse.predictions
        # limit: 5
        # template: _.template  """
        #                       <% if (value) { %>
        #                       <strong><%= value %></strong>
        #                       <% } %>
        #                       """
      ]

      if Parse.User.current() and Parse.User.current().get("network")

        @vars[0].local = Parse.User.current().get("network").properties.map (p) ->
            value: p.get("title")
            img_src: p.cover("tiny")
            url: p.url()
            tokens: _.union(p.get("title").split(" "), p.get("thoroughfare").split(" "), [p.get("locality")])
        @vars[0].prefetch = 
            url: "https://api.parse.com/1/classes/Property?where=" + 
                  encodeURIComponent(JSON.stringify({network: Parse.User.current().get("network").id}))
            filter: (parsedResponse) ->
              return [] if parsedResponse.results.length is 0
              _.map parsedResponse.results, (p) ->
                value: p.title
                img_src: if p.image_tiny then p.image_tiny else "/img/fallback/property-tiny.png"
                url: "/properties/#{p.objectId}"
                tokens: _.union(p.title.split(" "), p.thoroughfare.split(" "), [p.locality])

        @vars[3] = 
          name: 'tenants'
          header: "<span class='nav-header'>#{i18nCommon.classes.Tenants}</span>"
          local: Parse.User.current().get("network").tenants.map (t) ->
            p = t.get("profile")
            value: p.name()
            img_src: p.cover("tiny")
            url: p.url()
          prefetch: 
            url: "https://api.parse.com/1/classes/Tenant?include=profile&where=" + 
                  encodeURIComponent(JSON.stringify({network: Parse.User.current().get("network").id}))
            filter: (parsedResponse) ->
              return [] if parsedResponse.results.length is 0
              _.map parsedResponse.results, (t) ->
                p = t.profile
                value: t.profile.first_name + " " + t.profile.last_name
                img_src: if p.image_tiny then p.image_tiny else "/img/fallback/avatar-tiny.png"
                url: "/users/#{t.profile.objectId}"
          limit: 10
          template: _.template  """
                                <% if (value) { %>
                                <a href="<%= url %>">
                                  <img src="<%= img_src %>" class="photo-tiny" width="32" height="32">
                                  <strong><%= value %></strong>
                                </a>
                                <% } %>
                                """



        # Keep the local vars active in search
        # ------------------------------------

        @listenTo Parse.User.current().get("network").properties, "add reset", =>
          @$('.search-query').typeahead 'destroy'
          @vars[0].local = Parse.User.current().get("network").properties.map (p) ->
            value: p.get("title")
            img_src: p.cover("tiny")
            url: p.url()
            tokens: _.union(p.get("title").split(" "), p.get("thoroughfare").split(" "), [p.get("locality")])          

          @$('.search-query').typeahead @vars

        @listenTo Parse.User.current().get("network").tenants, "add reset", =>
          @$('.search-query').typeahead 'destroy'
          @vars[2].local =  Parse.User.current().get("network").tenants.map (t) ->
            p = t.get("profile")
            name = p.name()
            pos = name.indexOf("@")
            name = name.substr(0,pos) if pos > 0
            
            value: name
            img_src: p.cover("tiny")
            url: p.url()
          @$('.search-query').typeahead @vars

    # typeahead widget takes care of navigation.
    doNothing : (e) => e.preventDefault()

    googleSearch : (e, data) => 
      if data.reference
        data.location = _.map(data.terms, (t) -> t.value).join("--").replace(" ", "-")
        @trigger "google:search", data

    render : =>
      @$el.html JST["src/js/templates/helper/search.jst"](i18nCommon: i18nCommon)

      @$('.search-query').on "typeahead:selected", @googleSearch
      @$('.search-query').typeahead @vars
      @
      
    reset : =>
      @$('.search-query').typeahead('destroy')
      @initDatasets()
      @$('.search-query').typeahead @vars
      