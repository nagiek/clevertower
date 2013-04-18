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
      Parse.Dispatcher.on "user:logout", @clear

    search : (e) ->
      e.preventDefault()

    render : ->
      @$el.html JST["src/js/templates/helper/search.jst"](i18nCommon: i18nCommon)

      if Parse.onNetwork
        
        # Parse.User.current().get("network").properties.fetch
        #   success: ->
                 
        Parse.User.current().get("network").prep("properties")
                        
        @$('#search').typeahead [
          name: 'properties'
          header: "<span class='nav-header'>#{i18nCommon.classes.Properties}</span>"
          local: Parse.User.current().get("network").properties.map (p) ->
            title: p.get("title")
            img_src: p.cover("tiny")
            value: p.url()
            tokens: _.union(p.get("title").split(" "), p.get("thoroughfare").split(" "), [p.get("locality")])
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
            beforeSend: (jqXhr, settings) ->
              jqXhr.setRequestHeader "X-Parse-Application-Id", window.APPID
              jqXhr.setRequestHeader "X-Parse-REST-API-Key", window.RESTAPIKEY
            filter: (parsedResponse) ->
              return [value:false, title: i18nCommon.errors.no_results ] if parsedResponse.results.length is 0
              _.map parsedResponse.results, (p) ->
                title: p.title
                img_src: if p.image_tiny then p.image_tiny else "/img/fallback/property-tiny.png"
                value: "/properties/#{p.objectId}"
                tokens: _.union(p.title.split(" "), p.thoroughfare.split(" "), [p.locality])
          
          limit: 10
          template: _.template  """
                                <% if (value) { %>
                                <a href="<%= value %>">
                                  <img src="<%= img_src %>" class="photo-tiny" width="32" height="32">
                                  <strong><%= title %></strong>
                                </a>
                                <% } else { %>
                                <span class="empty"><%= title %></span>
                                <% } %>
                                """
          
        ,
          name: 'tenants'
          header: "<span class='nav-header'>#{i18nCommon.classes.Tenants}</span>"
          # template: '<p><strong>{{value}}</strong> – {{year}}</p>'
          # engine: Hogan
          limit: 10
          local: [
            'eh'
            'bee'
            'see'
            'dee'
          ]
        ]
      
      @
      
    clear : ->
      @$('#search').typeahead('destroy')
      @remove()
      