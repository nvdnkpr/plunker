#= require ../vendor/angular
#= require ../vendor/angular-cookies

#= require ../vendor/postmessage

#= require ../services/url


module = angular.module("plunker.session", ["ngCookies", "plunker.url"])

module.factory "session", ["$http", "$rootScope", "$cookies", "url", ($http, $rootScope, $cookies, url) ->
  new class Session
    constructor: ->
      angular.copy(_plunker.session, @) if _plunker and _plunker.session
      
      pm.bind "oauth:success", angular.bind(@, @handleAuth)
      pm.bind "oauth:error", angular.bind(@, @handleError)
      
      $cookies.plnk_session = @id
    
    upgrade: ->
      console.log "Upgrade", arguments...
      
    login: (width = 1000, height = 650) ->
      screenHeight = screen.height
      left = Math.round((screen.width / 2) - (width / 2))
      top = 0
      if (screenHeight > height)
          top = Math.round((screenHeight / 2) - (height / 2))
          
      login = window.open "#{url.www}/auth/github", "Sign in with Github", """
        left=#{left},top=#{top},width=#{width},height=#{height},personalbar=0,toolbar=0,scrollbars=1,resizable=1
      """

      if login then login.focus()
    
    logout: ->
      self = @
      
      request = $http
        url: @user_url
        method: "DELETE"
      
      request.then (response) ->
        console.log "logout:success", response
        angular.copy(response.data, self)
      , (error) ->
        console.error "logout:error", arguments...
    
    handleError: (error) ->
      console.error "oauth:error", arguments...
        
    handleAuth: (auth) ->
      self = @
      
      request = $http
        url: @user_url
        method: "POST"
        data: { service: auth.service, token: auth.token }

      request.then (response) ->
        angular.copy(response.data, self)
      , (error) ->
        console.error "login:error", arguments...
]