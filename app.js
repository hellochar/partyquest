
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');
var livereload = require('connect-livereload');

var app = express();

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
  app.use(livereload());
}

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));
app.use('/js/vendor', express.static(path.join(__dirname, 'bower_components')));
app.use(express.static(path.join(__dirname, 'compiled')));

app.get('/', routes.index);

var server = http.createServer(app);
var io = require("socket.io").listen(server)
server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});

require('fs').writeFileSync('.rebooted', 'rebooted')
