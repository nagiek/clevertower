module.exports = (app) ->
  NotFound = (msg) ->
    @name = 'NotFound'
    Error.call(@, msg)
    Error.captureStackTrace(@, arguments.callee)

  NotFound.prototype.__proto__ = Error.prototype

  # Catch all

  # app.all '*', notFound = (req, res, next) ->
  #    throw new NotFound

  # Load 404 page
  app.error (err, req, res, next) ->
      if (err instanceof NotFound)
          res.render('404')
      else
          next(err)

  # Load 500 page
  app.error (err, req, res) ->
    console.log(err)
    res.render('500', { error: err })

  return app
