#  Set all global variables
helpers = require './helpers'
controller = {}
app = {}
db = {}

# Constructor

module.exports = (_app) ->
  app = _app
  db  = app.set 'db'
  return controller


#######################################################################
# RESTful service routes
# fetch latest entries
controller.latest = (req, res) ->
  BlogPost = db.main.model('BlogPost')
  BlogPost.find({}, ['title', 'created', 'slug'], { limit: 3 })
          .sort('created', -1)
          .execFind( (err, posts) ->
            docs = []
            for post in posts
              doc = post.doc
              doc.url = post.url
              docs.push(doc)
            res.json(docs)
          )

# rss feed route
controller.rss = (req, res, next) ->
  BlogPost = db.main.model('BlogPost')
  BlogPost.find().limit(50)
          .sort('created', -1)
          .execFind( (err, posts) ->
            if (err)
              return next(new Error('There are no Posts'))
            else
              # render rss template using posts
              res.contentType('.rss')
              res.render('xml/rss', {
                layout: false,
                selfclosetags: false,
                posts: posts
              })
            )

##########################################################################
# Public Blog routes
# index route, load page 1 of blog
controller.posts = (req, res) ->
  BlogPost = db.main.model('BlogPost')
  BlogPost.find().limit(10)
    .sort('created', -1)
    .execFind(
      (err, posts) ->
        res.json posts
    )

# paging route, load requested page from database
# app.get '/page/:page/', (req, res) ->
#   # find blogposts for page
#   res.render 'index', { title: 'Paged Indexpage'}

# about route
# app.get '/about', (req, res) ->
#   res.render 'about'

# detail route
controller.postBySlug =  (req, res, next) ->
  BlogPost = db.main.model('BlogPost')
  # parse params as integers
  dateparts = helpers.parseDateInts(req.params)
  if (!dateparts)
    return next(new NotFound('Blogpost not found for given date'))

  whereClause = helpers.preparePostWhereclause(dateparts, req.params.slug)
  BlogPost.findOne().where(whereClause).execFind((err, post) ->
    if (!post)
      return next(new NotFound('Blogpost not found'))
    else
      res.json post
  )

# save comment
controller.saveComment = (req, res) ->
  BlogPost = db.main.model('BlogPost')
  dateparts = helpers.parseDateInts(req.params)
  if (!dateparts)
    return next(new NotFound('Blogpost not found'))

  whereClause = helpers.preparePostWhereclause(dateparts, req.params.slug)
  BlogPost.findOne().where(whereClause).execFind((err, post) ->
    if (!post)
      return next(new NotFound('Blogpost not found'))
    else
      # append comment
      comment =
        author: req.body.comment.author
        body: req.body.comment.body
        title: req.body.comment.title
        date: new Date()
      post.comments.$push(comment)

      commentCreationFailed = ->
        req.flash('error', 'Comment not saved')
        # res.render 'blogpost/detail', { post: post }

      post.save((err) ->
        if (err)
          return commentCreationFailed()
        req.flash('info', 'Thanks. Your comment has been saved!')
        res.redirect('/' + req.params.year + '/' + req.params.month + '/' + req.params.day + '/' + req.params.slug + '/')
      )
  )

# tag search route
# app.get '/tags/:tag', (req, res) ->
#   # find blogposts matching requested tag
#   res.render 'index', { title: 'Tagsearch Indexpage' }

# tag list route
# app.get '/tags', (req, res) ->
#   # find all tags using mapreduce
#   map = ->
#     if (!this.tags)
#       return
#     for (idx in this.tags)
#       emit(this.tags[idx], 1)

#   reduce = (prev, curr) ->
#     count = 0
#     for (idx in curr)
#       count += curr[idx]
#     return count
