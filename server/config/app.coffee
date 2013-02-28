# Load dependencies
express       = require 'express'
less          = require 'less'
nib           = require 'nib'
config        = require './config'
routes        = require './routes'
environment   = require './environment'
errors        = require './errors'
hooks         = require './hooks'

# util        = require 'util'
helpers     = require '../controllers/helpers'

#
# Exports
#
module.exports = ->
  # Create Server
  app = express()

  helpers(app)

  # Load Expressjs config
  config(app)

  # Load Environmental Settings
  environment(app)

  # Not 3.x compatible
  # Load error routes + pages
  # errors(app)

  # Load routes config
  routes(app)

  # Load hooks
  hooks(app)

  return app
