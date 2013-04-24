define [
  "jquery"
  "underscore"
  "backbone"
  "models/Property"
  "i18n!nls/common"
  'templates/helper/search'
], ($, _, Parse, Property, i18nCommon) ->

  class SearchView extends Parse.View
    
    el: '#search-menu'
    
    events:
      'submit form': 'search'

    initialize : ->
      _.bindAll @, 'search', 'render', 'clear'

      Parse.Dispatcher.on "user:logout", @clear

    search : (e) ->
      # typeahead widget takes care of navigation.
      e.preventDefault()

    render : ->
      @$el.html JST["src/js/templates/helper/search.jst"](i18nCommon: i18nCommon)

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
              value: p.title
              img_src: if p.image_tiny then p.image_tiny else "/img/fallback/property-tiny.png"
              url: "/properties/#{p.objectId}"
              tokens: _.union(p.title.split(" "), p.thoroughfare.split(" "), [p.locality])
        limit: 10
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
        limit: 10
        template: _.template  """
                              <% if (value) { %>
                              <a href="<%= url %>">
                                <img src="<%= img_src %>" class="photo-tiny" width="32" height="32">
                                <strong><%= value %></strong>
                              </a>
                              <% } %>
                              """
      ]

      if Parse.onNetwork and Parse.User.current()

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

        @vars[2] = 
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

        Parse.User.current().get("network").properties.on "add reset", =>
          @$('#search').typeahead 'destroy'
          @vars[0].local = Parse.User.current().get("network").properties.map (p) ->
            value: p.get("title")
            img_src: p.cover("tiny")
            url: p.url()
            tokens: _.union(p.get("title").split(" "), p.get("thoroughfare").split(" "), [p.get("locality")])          

          @$('#search').typeahead @vars

        Parse.User.current().get("network").tenants.on "add reset", =>
          @$('#search').typeahead 'destroy'
          @vars[2].local =  Parse.User.current().get("network").tenants.map (t) ->
            p = t.get("profile")
            name = p.name()
            pos = name.indexOf("@")
            name = name.substr(0,pos) if pos > 0
            
            value: name
            img_src: p.cover("tiny")
            url: p.url()

          @$('#search').typeahead @vars
          
        # Parse.User.current().get("network").managers.on "add reset", =>
        #   @$('#search').typeahead 'destroy'
        #   @vars[2].local=  Parse.User.current().get("network").managers.map (t) ->
        #     p = t.get("profile")
        #     value: p.name()
        #     img_src: p.cover("tiny")
        #     url: p.url()
        #   @$('#search').typeahead @vars

      else
        @$('#search').typeahead @vars
      
      @
      
    clear : ->
      @$('#search').typeahead('destroy')
      @remove()
      