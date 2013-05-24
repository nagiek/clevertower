module.exports = (app) ->
  port = process.env.PORT || 3000

  app.configure 'local', ->

    app.set('host', 'localhost')
    app.set('port', port)
    app.set('ENV','local')

  app.configure 'production', ->

    app.set('host', 'satio.no.de')
    app.set('port', port)
    app.set('ENV','production')

  return app
