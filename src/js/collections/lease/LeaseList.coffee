define [
  'jquery',
  'underscore',
  'backbone',
  'models/Lease'
], ($, _, Parse, Lease) ->

  class LeaseList extends Parse.Collection

    # Reference to this collection's model.
    model: Lease
    
    initialize: (attrs) ->
      @property = attrs.property
      @query = new Parse.Query(Lease)
      @query.equalTo "property", @property

    url:  ->
      "/properties/#{@property.get "id"}/leases"

    # query: ->
    #   query = new Parse.Query(Lease)
    #   query.equalTo "property", @property
    #   query
      
    comparator = (lease) ->
      title = lease.get("unit").get("title")
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title