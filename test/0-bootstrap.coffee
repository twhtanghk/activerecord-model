path = require 'path'
{load} = require '../index'

before ->
  global.sails = {}
  sails.config = load __dirname, path.dirname(__dirname)
  console.log sails.config
