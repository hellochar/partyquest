
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');
var _ = require('underscore');
var coffeescript = require("connect-coffee-script");
var cors = require('cors');

var app = express();

app.use(cors());

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
  var livereload = require('connect-livereload');
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

app.use(coffeescript({
    src: path.join(__dirname, 'coffee'),
    bare: true,
    dest: path.join(__dirname, 'compiled'),
}));

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'compiled')));
app.use('/js/vendor', express.static(path.join(__dirname, 'bower_components')));

app.get('/', routes.index);

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

var DIRECTIONS = ['left', 'right', 'up', 'down']

// I'm a slave to party-quest.com if i'm in dev mode
if ('development' == app.get('env')) {
    var io_client = require("socket.io-client");
    var masterUrl = process.env.MASTER_URL || "party-quest.com/slave"
    console.log("Starting in slave mode to ", masterUrl)
    var controller = io_client.connect(masterUrl)

    controller.on('connect', function() {
        console.log("slave connected to master!")

        controllersIo.on('connection', function (socket) {
            console.log("emitted newPlayer to master")

            controller.emit('newPlayer')
            socket.on('disconnect', function() {
                console.log("emitted lostPlayer to master")
                controller.emit('lostPlayer')
            });
            _.each(DIRECTIONS, function(dir) {
                socket.on(dir, function() {
                    console.log("emitted",dir,"to master")
                    controller.emit(dir);
                });
            });
        });

    });

} else {

    app.get('/game', routes.game);

    var gamesIo = io.of('/game')
    var slavesIo = io.of('/slave')

    var numPlayers = 0

    function updateNumPlayers() {
        gamesIo.emit("players", numPlayers)
    }

    controllersIo.on('connection', function (socket) {

        numPlayers += 1

        updateNumPlayers()

        _.each(DIRECTIONS, function(dir) {
            socket.on(dir, function() {
                gamesIo.emit(dir);
            });
        });

        socket.on('disconnect', function() {
            numPlayers -= 1
            updateNumPlayers()
        })
    });

    gamesIo.on("connection", function (socket) {
        updateNumPlayers()
    })

    // slaves can say the following messages to a master:
    //  newPlayer -> increment player number
    //  lostPlayer -> decrement player number
    //  left/right/up/down -> go in direction
    slavesIo.on("connection", function (socket) {

        socket.on("newPlayer", function() {
            numPlayers += 1
            updateNumPlayers()
        });
        socket.on("lostPlayer", function() {
            numPlayers -= 1
            updateNumPlayers()
        });

        _.each(DIRECTIONS, function(dir) {
            socket.on(dir, function() {
                gamesIo.emit(dir);
            });
        });
    })
}

require('fs').writeFileSync('.rebooted', 'rebooted')
