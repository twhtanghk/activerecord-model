    module.exports =

      proxy:

url to access api for http reverse proxy 

        url: 'https://abc.com/ustream'
        
model to acccess http reverse proxy api

        model: ->
          stamp = arModel
            .model arModel.proxy.url
            .use arModel.api().use arModel.oauth2.getOpts
