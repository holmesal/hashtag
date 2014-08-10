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
    'luegg.directives'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'

      # General-purpose user dashboard
      .when '/dashboard',
        templateUrl: 'views/dashboard.html'
        controller: 'DashboardCtrl'
        resolve:
          user: ['User', (User) -> User.getUser()]

      # Handle named channels in the route
      .when '/:channel',
        templateUrl: 'views/stream.html'
        controller: 'StreamCtrl'
        resolve: 
          channel: ['ChannelUtils', '$route', (ChannelUtils, $route) -> ChannelUtils.getChannel $route.current.params.channel]

      .otherwise
        redirectTo: '/dashboard'

  .run ($rootScope, $location, $firebase, NodeWebkit) ->

    # Some channel names are just not allowed
    # TODO - store these in Firebase instead
    $rootScope.notAllowed = ['discover', 'login']

    # TODO - separate dev and production firebases
    $rootScope.firebaseURL = 'http://shortwave-dev.firebaseio.com'
    $rootScope.rootRef = new Firebase $rootScope.firebaseURL

    # Catch errors in changing location
    $rootScope.$on '$routeChangeError', ->
      console.log 'failed to change route!!!'

    # On successful login, update the user and go to the dashboard
    $rootScope.$on '$firebaseSimpleLogin:login', (e, authUser) ->
      console.log 'login event from app.coffee'
      console.log authUser

      # Update this user's data
      userInfoRef = $rootScope.rootRef.child "users/#{authUser.uid}/profile"
      userInfoRef.update 
        photo: authUser.thirdPartyUserData.picture.data.url 
        firstName: authUser.thirdPartyUserData.first_name

      # Go to the dashboard
      $location.path '/dashboard'

    # On logout, go to the landing page
    $rootScope.$on '$firebaseSimpleLogin:logout', ->
      $location.path '/'

    # On login error, log that shit
    $rootScope.$on '$firebaseSimpleLogin:error', (e, err) ->
      console.error 'error logging in with firebase'
      console.error err

    # Log in this user with firebase
    # TODO - move login checking out to a service that does it in the route resolve
    # OR - just make a route resolver that is able to hold up the route change until this auth comes back either way. Ugh this sounds familiar
    # $rootScope.rootRef = rootRef = new Firebase $rootScope.firebaseURL
    # auth = new FirebaseSimpleLogin rootRef, (err, authUser) =>
    #   console.log 'auth done'
    #   if err
    #     console.error err
    #   else
    #     # If the user is logged in, redirect to one of your channels. Your first one?
    #     if authUser

    #       # Keep the authUser, this won't change
    #       $rootScope.authUser = authUser

    #       # Bind to the user
    #       userRef = rootRef.child "users/#{authUser.uid}"
    #       $rootScope.user = $firebase userRef

    #       # Update this user's data
    #       userInfoRef = rootRef.child "users/#{authUser.uid}/profile"
    #       userInfoRef.update 
    #         photo: authUser.thirdPartyUserData.picture.data.url 
    #         firstName: authUser.thirdPartyUserData.first_name

    #       # console.error 'should change path here to go to their home screen'
    #       console.log 'changing path!'
    #       $rootScope.$apply ->
    #         $location.path '/dashboard'

