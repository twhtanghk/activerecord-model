    _ = require 'lodash'
    _.defaults = require 'merge-defaults'
    glob = require 'glob'

- [promise](promise.html)
- [api](api.html)
- [oauth2](oauth2.html)
- [armodel](armodel.html)
- [proxy](proxy.html)
- [docker](docker.html)

    global.sails ?= {}
    sails.config ?= {}
     
    module.exports = (list...) ->
      if list.length == 0
        list = [ "#{__dirname}/config/*.litcoffee" ]

      addFile = (cfg, file) ->
        _.defaults cfg, require file

      addPattern = (cfg, pattern) ->
        glob
          .sync pattern
          .reduce addFile, cfg

      _.reduce list, addPattern, sails.config
