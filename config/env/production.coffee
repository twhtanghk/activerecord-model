module.exports =
  oauth2:
    url:
      authorize: 'https://abc.com/auth/oauth2/authorize/'
      verify: 'https://abc.com/auth/oauth2/verify/'
      token: 'https://abc.com/auth/oauth2/token/'
    client:
      id: 'client_id'
      secret: 'client_secret'
    user:
      id: 'user_id'
      secret: 'user_secret'
    scope: [
      'User'
    ]
  vm:
    url: 'http://abc.com/vm/api/vm'
  proxy:
    url: 'https://abc.com/upstream'
  docker:
    url: 'http://192.168.121.1:2375'
