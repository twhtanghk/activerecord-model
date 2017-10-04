_ = require 'lodash'
_.defaults = require 'merge-defaults'

before ->
  global.sails = {}
  sails.config = require '../config/env/production.coffee'
  _.defaults sails.config, require '../index'
