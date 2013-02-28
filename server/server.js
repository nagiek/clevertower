require('coffee-script');
require('./config/exceptions');

if(!process.env.NODE_ENV) process.env.NODE_ENV="local"

//  Load boot file and fire away!
var app = require('./config/app')();
var port = process.env.PORT || 3000;

app.listen(port);

console.log('CleverTower running as %s on http://%s:%d',
  app.get('env'),
  app.get('host'),
  app.get('port')
);
