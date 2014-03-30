
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');
var livereload = require('connect-livereload');
var _ = require('underscore');

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
app.get('/game', routes.game);

var server = http.createServer(app);
var io = require("socket.io").listen(server)
server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

/**************************************
 *       GAME LOGIC HERE LOL
 **************************************
 */

var controllersIo = io.of('/controller')
var gamesIo = io.of('/game')

var DIRECTIONS = ['left', 'right', 'up', 'down']

controllersIo.on('connection', function (socket) {

    var numberOfSockets = Object.keys(controllersIo.manager.connected).length;
    gamesIo.emit("players", numberOfSockets)

    _.each(DIRECTIONS, function(dir) {
        socket.on(dir, function() {
            gamesIo.emit(dir);
        });
    });

    socket.on('disconnect', function() {
        var numberOfSockets = Object.keys(controllersIo.manager.connected).length;
        gamesIo.emit("players", numberOfSockets)
    });
});

require('fs').writeFileSync('.rebooted', 'rebooted')
