var require = {
    baseUrl: "js",
    paths: {
        b2: 'b2',
        backbone: ['vendor/backbone/backbone'],
        box2d: ['vendor/Box2dWeb-2.1.a.3'],
        canvasquery: ['vendor/canvasquery'],
        "dat.gui": 'vendor/dat.gui',
        'canvasquery.framework': ['vendor/canvasquery.framework'],
        handlebars: ['vendor/handlebars/handlebars.runtime.amd'],
        fastclick: "vendor/fastclick/lib/fastclick",
        jquery: ['vendor/jquery-1.9.1.min', 'ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min'],
        "jquery.color": "vendor/jquery.color-2.1.2",
        noise: ['vendor/noise'],
        pathfinding: ['vendor/PathFinding.js/lib/pathfinding-browser'],
        phaser: ['vendor/phaser'],
        seedrandom: ['vendor/seedrandom'],
        'socket.io': ['/socket.io/socket.io'],
        stats: ['vendor/stats'],
        tapjs: "vendor/tap.js/tap",
        underscore: ['vendor/underscore/underscore']
    },
    shim: {
        box2d: {
            exports: 'Box2D'
        },
        canvasquery: {
            exports: ['cq', 'CanvasQuery']
        },
        'canvasquery.framework': {
            deps: ['canvasquery'],
            exports: ['cq', 'CanvasQuery']
        },
        "dat.gui": {
            exports: 'dat'
        },
        "jquery.color": ["jquery"],
        noise: {
            exports: 'ClassicalNoise'
        },
        phaser: {
            exports: "Phaser"
        },
        settings: {
            exports: 'settings'
        },
        stats: {
            exports: 'Stats'
        },
        tapjs: {
            exports: "Tap"
        },
        underscore: {
            exports: '_'
        }
    }
};

