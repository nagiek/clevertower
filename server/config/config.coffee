#
#  Load dependencies
#

express   = require 'express'
path      = require 'path'
nib       = require 'nib'

# Exports

module.exports = (app) ->

  # Compile Hack for Stylus
  #  Replaced by connect-assets
  # function compile(str, path) {
  #   return stylus(str)
  #     .set('filename', path)
  #     .include(nib.path);
  # }

  # Configure expressjs
  app.configure ->
    app.use express.logger()
    # app.register '.html', require('ejs')
    app.set 'views', __dirname + '/../views'
    app.set 'view engine', 'jade'
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.errorHandler({dumpException: true, showStack: true})
    # app.use app.router
    app.use express.static __dirname + '/../../public'
    # app.dynamicHelpers { messages: require('express-messages-bootstrap') }

  return app
