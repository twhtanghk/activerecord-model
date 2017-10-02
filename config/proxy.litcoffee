    module.exports =

      proxy:

url to access api for http reverse proxy 

        url: 'https://abc.com/ustream'
        
model to acccess http reverse proxy api

        model: ->
          stamp = sails.config
            .armodel sails.config.proxy.url
            .use sails.config.api().use sails.config.oauth2.getOpts
