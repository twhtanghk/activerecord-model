    module.exports =

      vm:

url to access api for http reverse proxy 

        url: 'https://abc.com/vm'
        
model to acccess http reverse proxy api

        model: ->
          stamp = sails.config
            .armodel sails.config.vm.url
            .use sails.config.api().use sails.config.oauth2.getOpts
