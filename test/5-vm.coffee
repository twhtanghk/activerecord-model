co = require 'co'

describe 'vm', ->
  Vm = sails.config.vm.model()

  it 'fetchAll', ->
    co Vm.fetchAll()
      .then (gen) ->
        for i from gen()
          console.log i
