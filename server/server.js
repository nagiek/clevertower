require('coffee-script');
require('./config/exceptions');

var fs = require('fs');
var http = require('http');
var https = require('https');

var privateKey  = fs.readFileSync('server/sslcert/server.key').toString();
var certificate = fs.readFileSync('server/sslcert/server.crt').toString();
var credentials = {key: privateKey, cert: certificate};

if(!process.env.NODE_ENV) process.env.NODE_ENV="local"

//  Load boot file and fire away!
var app = require('./config/app')();
var port = process.env.PORT || 3000;

// app.listen(port);


// var app = express();

http.createServer(app).listen(3000);
https.createServer(credentials, app).listen(8443);

console.log('CleverTower running as %s on http://%s:%d',
  app.get('env'),
  app.get('host'),
  app.get('port')
);
