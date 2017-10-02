    _ = require 'lodash'
    _.defaults = require 'merge-defaults'
    glob = require 'glob'

    addConfig = (cfg, file) ->
      _.defaults cfg, require file

- [promise](promise.html)
- [api](api.html)
- [oauth2](oauth2.html)
- [armodel](armodel.html)
- [proxy](proxy.html)
- [docker](docker.html)

    global.sails ?= {}
    sails.config ?= {}
    sails.config = glob
      .sync "./config/env/#{process.env.NODE_ENV || 'production'}.coffee"
      .concat glob.sync './config/*.litcoffee'
      .reduce addConfig, sails.config
    module.exports = sails.config
