'use strict';

module.exports = function(grunt) {

    var path = require('path');

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        clean: {
            options: {force: true},
            compiled: ['compiled/js/'],
        },
        env: {
            dev : {
                NODE_ENV: 'development',
            },
            slave : {
                NODE_ENV: 'slave',
                MASTER_URL: 'party-quest.com/slave',
                PORT: 80,
            },
        },

        watch: {
            options: {
                livereload: true,
            },
            coffee_changed: {
                files: 'coffee/**/*.coffee',
                tasks: '',
                options: {
                    spawn: false,
                    event: ['added', 'changed'],
                },
            },
            coffee_deleted: {
                files: 'coffee/**/*.coffee',
                tasks: '',
                options: {
                    spawn: false,
                    event: ['deleted'],
                },
            },
            server: {
                files: ['.rebooted'], // app.js writes to this dummy file when it loads
                tasks: '',
            },
            'public': {
                files: 'public/**/*.*',
                tasks: '',
            },
        },
        nodemon: {
            dev: {
                script: '<%= pkg.main %>',
                options: {
                    // My only server file is app.js, so only watch that
                    watch: ['<%= pkg.main %>'],
                    delay: 0.1, // restart app.js immediately
                },
            },
        },
        concurrent: {
            dev: {
                tasks: ['nodemon:dev', 'watch'],
                options: {
                    logConcurrentOutput: true,
                },
            },
        },

    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-env');
    grunt.loadNpmTasks('grunt-nodemon');

    grunt.event.on('watch', function(action, filepathString) {

        //should be of the form [coffee, dir1, dir2, ... file.coffee]
        var pathComponents = filepathString.split(path.sep)

        if(pathComponents[0] != "coffee") {
            return;
        }

        var jsPathComponents = ["compiled", "js"]
        jsPathComponents.push.apply(jsPathComponents, pathComponents.slice(1, -1))
        var new_filename = path.basename(filepathString, ".coffee") + ".js";
        jsPathComponents.push(new_filename);
        var js_filepath = jsPathComponents.join(path.sep)

        if(action == 'deleted') {
            console.log("deleting", js_filepath);
            grunt.file.delete(js_filepath);
        }
    });

    grunt.registerTask('default', ['env:dev', 'concurrent:dev']);
    grunt.registerTask('slave', ['env:slave', 'concurrent:dev']);
}

