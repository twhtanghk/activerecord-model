    _ = require 'lodash'
    _.defaults = require 'merge-defaults'
    glob = require 'glob'

- [promise](promise.html)
- [api](api.html)
- [oauth2](oauth2.html)
- [armodel](armodel.html)
- [proxy](proxy.html)
- [docker](docker.html)

    list = [ "#{__dirname}/config/*.litcoffee" ]

    addFile = (cfg, file) ->
      _.defaults cfg, require file

    addPattern = (cfg, pattern) ->
      glob
        .sync pattern
        .reduce addFile, cfg

    module.exports =
      _.reduce list, addPattern, {}
