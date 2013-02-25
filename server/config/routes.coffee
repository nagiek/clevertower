module.exports = (app) ->

  # blog    = require('./blogpost_rest')(app)
  # admin   = require('./admin_rest')(app)
  # helpers  = require('./helpers')(app)

  # app.get '/*', (req, res) ->
  app.get '/', (req, res) ->
    res.render 'index'


  # # Load Root
  # app.get '/admin', helpers.loadUser, admin.index
  # 
  # # User + Session
  # app.get '/admin/login', admin.login
  # app.post '/admin/session', admin.session
  # app.get '/admin/logout', helpers.loadUser, admin.logout
  # app.get '/admin/user/new', helpers.loadUser, admin.newUser
  # app.post '/admin/user/create', helpers.loadUser,  admin.createUser
  # 
  # # Posts
  # app.get  '/admin/posts', helpers.loadUser, admin.index
  # app.get  '/admin/post/new', helpers.loadUser, admin.newPost
  # app.post '/admin/post/create', helpers.loadUser, admin.createPost
  # app.get '/admin/post/edit/:id', helpers.loadUser, admin.edit
  # app.put '/admin/post/edit/:id', helpers.loadUser, admin.update
  # app.del '/admin/post/:id', helpers.loadUser, admin.delete
  # 
  # # Public routes
  # app.get '/:year/:month/:day/:slug', blog.postBySlug
  # app.get '/posts' , blog.posts
  # app.get '/posts/latest' , blog.latest
  # app.get '/rss', blog.rss
  # app.post '/:year/:month/:day/:slug/comment', blog.saveComment
  # 
