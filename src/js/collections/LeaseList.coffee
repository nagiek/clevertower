define [
  'jquery',
  'underscore',
  'backbone',
  'models/Lease'
], ($, _, Parse, Lease) ->

  class LeaseList extends Parse.Collection

    model: Lease
      
    initialize: (models, attrs) ->
      @query = new Parse.Query("Lease").include("unit")
      if attrs.property
        @property = attrs.property
        @query.equalTo "property", @property
      else if attrs.unit
        @unit = attrs.unit
        @query.equalTo "unit", @unit

    # Filter down the list of all active leases
    active: ->
      @filter (lease) ->
        lease.isActive()

    # Filter down the list of all inactive leases
    inactive: ->
      @without.apply this, @active()

    # query: ->
    #   query = new Parse.Query(Lease)
    #   query.equalTo "property", @property
    #   query
      
    comparator: (lease) ->
      title = lease.get("unit").get("title")
      char = title.charAt title.length - 1
      # Slice off the last digit if it is a letter and add it as a decimal
      if isNaN(char)
        Number(title.substr 0, title.length - 1) + char.charCodeAt()/128
      else
        Number title