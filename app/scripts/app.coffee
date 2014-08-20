'use strict'

###*
 # @ngdoc overview
 # @name shortwaveApp
 # @description
 # # shortwaveApp
 #
 # Main module of the application.
###
angular
  .module('shortwaveApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'firebase',
    'luegg.directives',
    'angularFileUpload',
    'emoji',
    'monospaced.elastic',
    'angularMoment'
  ])
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      # .when '/about',
      #   templateUrl: 'views/about.html'
      #   controller: 'AboutCtrl'

      # General-purpose user dashboard
      .when '/dashboard',
        templateUrl: 'views/dashboard.html'
        controller: 'DashboardCtrl'
        resolve:
          user: ['User', (User) -> User.get()]

      # Handle named channels in the route
      # .when '/:channel',
      #   templateUrl: 'views/stream.html'
      #   controller: 'StreamCtrl'
      #   resolve: 
      #     channel: ['ChannelUtils', '$route', (ChannelUtils, $route) -> ChannelUtils.getChannel $route.current.params.channel]

      # Invites go straight to the channels
      .when '/:channel',
        templateUrl: 'views/invite.html'
        controller: 'InviteCtrl'
        resolve:
          user: ['User', (User) -> User.get()]

      # .otherwise
      #   redirectTo: '/dashboard'

    # $locationProvider.html5Mode true


  .run ($rootScope, $location, $firebase, $firebaseSimpleLogin, NodeWebkit) ->

    # Some channel names are just not allowed
    # TODO - store these in Firebase instead
    $rootScope.notAllowed = ['discover', 'login']

    # TODO - separate dev and production firebases
    $rootScope.firebaseURL = 'http://shortwave-dev.firebaseio.com'
    $rootScope.rootRef = new Firebase $rootScope.firebaseURL

    # Handle auth
    # TODO - break this out into a service
    $rootScope.auth = new FirebaseSimpleLogin $rootScope.rootRef, (err) ->
      if err
        console.error err

    # Catch errors in changing location
    $rootScope.$on '$routeChangeError', ->
      console.log 'failed to change route!!!'

    # On successful login, update the user and go to the dashboard
    $rootScope.$on '$firebaseSimpleLogin:login', (e, authUser) ->
      console.info 'login event from app.coffee'
      # If we're on the home screen, go to the dashboard
      if $location.$$path is '/'
        $location.path '/dashboard'
    #   console.log authUser

    #   # Update this user's data
    #   userInfoRef = $rootScope.rootRef.child "users/#{authUser.uid}/profile"
    #   userInfoRef.update 
    #     photo: authUser.thirdPartyUserData.picture.data.url 
    #     firstName: authUser.thirdPartyUserData.first_name

    #   # Go to the dashboard
    #   $location.path '/dashboard'

    # On logout, take them to the login screen
    $rootScope.$on '$firebaseSimpleLogin:logout', ->
      console.log 'logout event from app.coffee'
      # $location.path '/'

    # On login error, log that shit
    $rootScope.$on '$firebaseSimpleLogin:error', (e, err) ->
      console.error 'error logging in with firebase'
      console.error err

  .constant 'amTimeAgoConfig',
    withoutSuffix: true



