# Load dependencies
express       = require 'express'
less          = require 'less'
Parse         = require('parse').Parse
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

  Parse.initialize 'z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu', 'NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm'

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
