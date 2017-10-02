    Promise = require 'bluebird'

promise to run action [while](https://github.com/zhuangya/ya-promise-while) cond evaluated as true

    Promise.while = require 'ya-promise-while'

promise to run action until cond evaluated as false

    Promise.until = (cond, action) ->
      first = true
      skipFirst = ->
        if first
          first = false
          return true
        else
          cond()
      Promise.while skipFirst, action

    module.exports =
      Promise: Promise
