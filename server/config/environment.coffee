Pusher   = require 'pusher'
push = {}

module.exports = (app) ->
  port = process.env.PORT || 3000

  app.configure 'local', ->
    # Setup pusher
    push = new Pusher
        appId  : '16815'
        appKey : '191d9e7fccb0ce60ebec'
        secret : 'ce1b66eaf7ed8faf5a02'

    app.set('host', 'localhost')
    app.set('port', port)
    app.set('ENV','local')

  app.configure 'production', ->
    # Setup pusher
    push = new Pusher
      appId  : 'YOUR_PUSHER_APP_ID'
      appKey : 'YOUR_PUSHER_APP_KEY'
      secret : 'YOUR_PUSHER_SECRET_KEY'

    app.set('host', 'satio.no.de')
    app.set('port', port)
    app.set('ENV','production')

    # Set pusher
  app.set 'pusher', { 'blog_post': push.channel('blog_post') }
  app.set 'pusher_key', push.options.appKey

  return app
