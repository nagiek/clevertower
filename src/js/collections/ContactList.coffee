define [
  'jquery',
  'underscore',
  'backbone',
], ($, _, Parse) ->

  class ContactList extends Parse.Collection
      
    initialize: (models, attrs) ->