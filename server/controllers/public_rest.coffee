#  Set all global variables
helpers = require './helpers'
Parse = require('parse').Parse
controller = {}
app = {}

# Constructor

module.exports = (_app) ->
  app = _app
  return controller


# RESTful service routes
# ----------------------

# Network
controller.network = (req, res) ->
  query = new Parse.Query("Network")
  query.get req.body.id, success: (network) ->
    if (network) then res.render 'network', network: network.toJSON()
    else error: message: 'access_denied'
  error: -> error: message: 'access_denied'

# Property
controller.property = (req, res) ->
  query = new Parse.Query("Property")
  query.get req.body.id, success: (property) ->
    if (property) then res.render 'property', property: property.toJSON(); console.log property
    else error: message: 'access_denied'
  error: -> error: message: 'access_denied'

# Listing
controller.listing = (req, res) ->
  query = new Parse.Query("Listing")
  query.get req.body.id, success: (listing) ->
    if (listing) then res.render 'listing', listing: listing.toJSON()
    else error: message: 'access_denied'
  error: -> error: message: 'access_denied'

# Listing
controller.outside = (req, res) ->

  cities = 
    "Montreal--QC--Canada": 'Originally called Ville-Marie, or "City of Mary", it is named after Mount Royal, the triple-peaked hill located in the heart of the city.'
    "Toronto--ON--Canada": 'Canada’s most cosmopolitan city is situated on beautiful Lake Ontario, and is the cultural heart of south central Ontario and of English-speaking Canada.'

  if cities[req.params.location] isnt ""
    name = req.params.location.split("--")[0]
    res.render 'outside', city: true, location: "/" + req.params.location, desc: cities[req.params.location], name: name
  else
   res.render 'outside', city: false, location: "", desc: ""