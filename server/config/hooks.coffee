# /**
#  * Load hooks
#  */

ev = require('../hooks/events')

# /**
#  * Exports
#  */
module.exports = (app) ->
  # Event hooks
  app.on('event:create_blog_post', ev.create_blog_post)
  app.on('event:update_blog_post', ev.delete_blog_post)
  app.on('event:delete_blog_post', ev.delete_blog_post)