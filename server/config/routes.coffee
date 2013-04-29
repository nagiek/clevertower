module.exports = (app) ->

  # blog      = require('./blogpost_rest')(app)
  # helpers   = require('./helpers')(app)
  nodes       = require('../controllers/public_rest')(app)

  # Facebook caching
  app.get '/fb-channel', (req, res) ->
    body = '<script type="text/javascript" src="//connect.facebook.net/en_US/all.js"></script>'
    res.setHeader 'Content-Type', 'text/html'
    res.setHeader 'Content-Length', body.length
    res.setHeader 'Expires', new Date(2015,1,1).toString()
    res.end body

  # Public routes for SEO
  app.get '/public/:propertyId/listing/:id' , nodes.listing
  app.get '/public/:id'                     , nodes.property
  app.get '/networks/:id'                   , nodes.network

  # Everything else
  app.get '*', (req, res) ->
    res.render 'index'