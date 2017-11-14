    _ = require 'lodash'
    _.defaults = require 'merge-defaults'
    glob = require 'glob'
    path = require 'path'

merge configuration from file into cfg

    addFile = (cfg, file) ->
      _.defaults cfg, require file

merge configuration from file pattern into cfg

    addPattern = (cfg, pattern) ->
      glob
        .sync pattern
        .reduce addFile, cfg

merge configuration from files config/env/prodcution.* and config/* under dir into cfg

    load = (cfg, dir) ->
        env = process.env.NODE_ENV || 'production'
        list = [
          "config/env/#{env}.litcoffee"
          "config/env/#{env}.coffee"
          "config/env/#{env}.js"
          "config/*.litcoffee"
          "config/*.coffee"
          "config/*.js"
        ]
        list = list.map (file) ->
          path.join dir, file
        list.reduce addPattern, cfg

load configuration from dir list

    module.exports = 
      load: (dir...) ->
        dir.reduce load, {}
