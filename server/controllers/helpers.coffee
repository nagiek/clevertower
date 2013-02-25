# Global variables
controller = {}
app = {}
db = {}

module.exports = (_app) ->
  app = _app
  db  = app.set('db')
  return controller


controller.parseDateInts = (params) ->
  y = parseInt(params.year)
  m = parseInt(params.month.trimLeft('0'))
  d = parseInt(params.day.trimLeft('0'))
  if (y == NaN || m == NaN || d == NaN)
    return null
  return {
    y: y
    m: m
    d: d
  }

controller.preparePostWhereclause = (date, slug) ->
  # // build search dates
  searchstart = new Date(Date.UTC(date.y, date.m - 1, date.d))
  searchend = new Date(Date.UTC(date.y, date.m - 1, date.d, 23, 59, 59))
  # return where clause structure
  return {
    slug: slug
    created: { $gte: searchstart }
    created: { $lte: searchend }
  }

controller.loadUser = (req, res, next) ->
  if (app.set('disableAuthentication') == true)
    next
  else
    if (req.session.user_id)
      User = db.main.model('User')
      User.find({ '_id': req.session.user_id }, (err, user) ->
        if (user)
          req.currentUser = user
          next()
        else
          res.redirect '/admin/login'
      )
    else if (req.cookies.logintoken)
      authFromLoginToken(req, res, next)
    else
      res.redirect '/admin/login'

########################################################################
# authentication methods
controller.authFromLoginToken = (req, res, next) ->
  cookie = JSON.parse(req.cookies.logintoken)
  LoginToken  = db.main.model('LoginToken')
  User        = db.main.model('User')
  LoginToken.findOne({ email: cookie.email, token: cookie.token, series: cookie.series }, (err, token) ->
    if (!token)
      res.redirect '/admin/login'
      return
    User.findOne({ email: token.email }, (err, user) ->
      if (user)
        req.session.user_id = user.id
        req.currentUser = user

        token.token = token.randomToken()
        token.save( ->
          res.cookie 'logintoken',
                      token.cookieValue,
                      { expires: new Date(Date.now() + 2 * 604800000), path: '/' }
        )
        next()
      else
        res.redirect '/admin/login'
    )
  )

