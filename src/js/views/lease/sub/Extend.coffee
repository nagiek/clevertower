define [
  "moment"
  "views/lease/New"
  "templates/lease/sub/extend"
], (moment, NewLeaseView) ->

  class ExtendLeaseView extends NewLeaseView

  	initialize : (attrs) ->
      
      super
      @template = "src/js/templates/lease/sub/extend.jst"
      @cancel_path = "#{@baseUrl}/leases/#{@model.id}"

      delete @model.id
      delete @model.createdAt
      delete @model.updatedAt

      duration = moment(@model.get("end_date")).diff(moment(@model.get("start_date")), 'days')
      sd = moment(@model.get("end_date")).add(1, 'days')
      ed = moment(@model.get("end_date")).add(duration + 1, 'days')
      @model.set 
        start_date: sd
        end_date: ed

      @dates =
        start:  sd.format("L")
        end:    ed.format("L")