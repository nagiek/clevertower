# This is the main application configuration file.  It is a Grunt
# configuration file, which you can learn more about here:
# https://github.com/cowboy/grunt/blob/master/docs/configuring.md
module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-jst'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.initConfig
  
    pkg: grunt.file.readJSON 'package.json'
    
    # Converts Jade templates into HTML files.
    jade:
      all:
        files: [
          expand: true
          cwd: 'src/js/templates'
          src: ['**/*.jade']
          dest: 'public/js/app/templates'
          ext: '.html'  
        ]
        options:
          runtime: false
          client: false
          
    coffee:
      all: 
        files: [{
          expand: true
          cwd: 'src/js'
          src: ['**/*.coffee']
          dest: 'public/js/app/'
          ext: '.js'
        },{
          expand: true
          cwd: 'src/js'
          src: ['**/*.*.coffee']
          dest: 'public/js/app/'
          ext: '.js'
        },{
          expand: true
          cwd: 'cloud/Cloud'
          src: ['**/*.coffee']
          dest: 'cloud/Cloud'
          ext: '.js' 
        }]
      
          
    # LESS CSS
    less:
      development:
        files:
          'public/css/cali.css': 'src/css/cali.less'
      release:
        options:
          yuicompress: true
        files:
          'public/css/cali.min.css': 'src/css/cali.less'
    
    # Uglify JS
    uglify:
      release:
        files: [
          expand: true
          cwd: 'public/js/app'
          src: ['**/*.js']
          dest: 'public/js/app'
          ext: '.js'  
        ]
    
    # The jst task compiles all application templates into JavaScript
    # functions with the underscore.js template function from 1.2.4.  You can
    # change the namespace and the template options, by reading this:
    # https://github.com/gruntjs/grunt-contrib/blob/master/docs/jst.md
    #
    # The concat task depends on this file to exist, so if you decide to
    # remove this, ensure concat is updated accordingly.
    jst:
      all:
        files: [
          expand: true
          cwd: 'src/js/templates'
          src: ['**/*.jst']
          dest: 'public/js/app/templates'
          ext: '.js'
        ,
          expand: true
          cwd: 'src/js/templates'
          src: ['**/**/*.jst']
          dest: 'public/js/app/templates'
          ext: '.js'
        ,
          expand: true
          cwd: 'public/js/app/templates'
          src: ['**/*.html']
          dest: 'public/js/app/templates'
          ext: '.js'
        ]
        options:
          amdWrapper: true
        
    # The lint task will run the build configuration and the application
    # JavaScript through JSHint and report any errors.  You can change the
    # options for this task, by reading this:
    # https://github.com/cowboy/grunt/blob/master/docs/task_lint.md
    # lint:
    #   files: ["build/config.js", "app/**/*.js"]

    
    # The jshint option for scripturl is set to lax, because the anchor
    # override inside main.js needs to test for them so as to not accidentally
    # route.
    # jshint:
    #   options:
    #     scripturl: true

    
    # The concatenate task is used here to merge the almond require/define
    # shim and the templates into the application code.  It's named
    # dist/debug/require.js, because we want to only load one script file in
    # index.html.
    # concat:
    #   dist:
    #     src: ["vendor/almond/almond.js", "dist/debug/require.js"]
    #     dest: "dist/debug/require.js"
    #     separator: ";"

    
    # This task uses the MinCSS Node.js project to take all your CSS files in
    # order and concatenate them into a single CSS file named index.css.  It
    # also minifies all the CSS as well.  This is named index.css, because we
    # only want to load one stylesheet in index.html.
    # mincss:
    #   "dist/release/index.css": ["dist/debug/index.css"]

    
    # Takes the built require.js file and minifies it for filesize benefits.
    # min:
    #   "dist/release/require.js": ["dist/debug/require.js"]

    
    # Running the server without specifying an action will run the defaults,
    # port: 8000 and host: 127.0.0.1.  If you would like to change these
    # defaults, simply add in the properties `port` and `host` respectively.
    # Alternatively you can omit the port and host properties and the server
    # task will instead default to process.env.PORT or process.env.HOST.
    #
    # Changing the defaults might look something like this:
    #
    # server: {
    #   host: "127.0.0.1", port: 9001
    #   debug: { ... can set host and port here too ...
    #  }
    #
    #  To learn more about using the server task, please refer to the code
    #  until documentation has been written.
    # server:
    #   
    #   # Ensure the favicon is mapped correctly.
    #   files:
    #     "favicon.ico": "favicon.ico"
    # 
    #   
    #   # For styles.
    #   prefix: "app/styles/"
    #   debug:
    #     
    #     # Ensure the favicon is mapped correctly.
    #     files: "<config:server.files>"
    #     
    #     # Map `server:debug` to `debug` folders.
    #     folders:
    #       app: "dist/debug"
    #       "vendor/js/libs": "dist/debug"
    #       "app/styles": "dist/debug"
    # 
    #   release:
    #     
    #     # This makes it easier for deploying, by defaulting to any IP.
    #     host: "0.0.0.0"
    #     
    #     # Ensure the favicon is mapped correctly.
    #     files: "<config:server.files>"
    #     
    #     # Map `server:release` to `release` folders.
    #     folders:
    #       app: "dist/release"
    #       "vendor/js/libs": "dist/release"
    #       "app/styles": "dist/release"

    
    # The headless QUnit testing environment is provided for "free" by Grunt.
    # Simply point the configuration to your test directory.
    # qunit:
    #   all: ["test/qunit/*.html"]

    
    # The headless Jasmine testing is provided by grunt-jasmine-task. Simply
    # point the configuration to your test directory.
    # jasmine:
    #   all: ["test/jasmine/*.html"]

    # The watch task can be used to monitor the filesystem and execute
    # specific tasks when files are modified.  By default, the watch task is
    # available to compile CSS if you are unable to use the runtime compiler
    # (use if you have a custom server, PhoneGap, Adobe Air, etc.)
    watch:
      coffee:
        files: ['src/js/**/*.coffee', 'cloud/Cloud/**/*.coffee']
        tasks: 'coffee'
      jst:
        files: ['src/js/templates/**/*.jst', 'src/js/templates/**/**/*.jst']
        tasks: 'jst'
      jade:
        files: 'src/js/templates/*.jade'
        tasks: 'jade'
      less:
        files: 'src/css/*.less'
        tasks: 'less'
    
    # The clean task ensures all files are removed from the dist/ directory so
    # that no files linger from previous builds.
    clean: ["dist/"]



  
  # If you want to generate targeted `index.html` builds into the `dist/`
  # folders, uncomment the following configuration block and use the
  # conditionals inside `index.html`.
  #targethtml: {
  #  debug: {
  #    src: "index.html",
  #    dest: "dist/debug/index.html"
  #  },
  #
  #  release: {
  #    src: "index.html",
  #    dest: "dist/release/index.html"
  #  }
  #},

  # This task will copy assets into your build directory,
  # automatically.  This makes an entirely encapsulated build into
  # each directory.
  #copy: {
  #  debug: {
  #    files: {
  #      "dist/debug/app/": "app/**",
  #      "dist/debug/vendor/": "vendor/**"
  #    }
  #  },

  #  release: {
  #    files: {
  #      "dist/release/app/": "app/**",
  #      "dist/release/vendor/": "vendor/**"
  #    }
  #  }
  #}

  # The debug task will remove all contents inside the dist/ folder, lint
  # all your code, precompile all the underscore templates into
  # dist/debug/templates.js, compile all the application code into
  # dist/debug/require.js, and then concatenate the require/define shim
  # almond.js and dist/debug/templates.js into the require.js file.
  # grunt.registerTask "debug", "clean lint jst requirejs concat styles"

  # The release task will run the debug tasks and then minify the
  # dist/debug/require.js file and CSS files.
  # grunt.registerTask "release", "debug min mincss"
  

  grunt.registerTask "default", []

  grunt.registerTask "compile", ["jst", "less", "coffee", "jade"] # , "uglify"
  

  