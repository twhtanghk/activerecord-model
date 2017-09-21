config = require '../config.coffee'
co = require 'co'

describe 'docker', ->

  Container = config.docker.model.container()

  it 'list', ->
    co Container.fetchAll()
