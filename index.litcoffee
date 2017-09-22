    _ = require 'lodash'
    _.defaults = require 'merge-defaults'
    glob = require 'glob'

    addConfig = (cfg, file) ->
      _.defaults cfg, require file

- [promise](promise.html)
- [api](api.html)
- [oauth2](oauth2.html)
- [model](model.html)
- [proxy](proxy.html)
- [docker](docker.html)

    module.exports = global.arModel = glob
      .sync "./config/env/#{process.env.NODE_ENV || 'production'}.coffee"
      .concat glob.sync './config/*.litcoffee'
      .reduce addConfig, {}
