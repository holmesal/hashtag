'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller for the landing page - handle loggin in the user, etc.
###
angular.module('shortwaveApp')
  .controller 'MainCtrl', ($scope, $rootScope, $location, $timeout, $firebase, $firebaseSimpleLogin, $interval) ->

    # Log the time this screen loaded
    startTime = Date.now()
    minTime = 3000

    # TODO - move login checking out to a service that does it in the route resolve - right now said service exists, but this callback is in too many places...
    $scope.$auth = $firebaseSimpleLogin $rootScope.rootRef
    , (err, authUser) ->
      # console.log 'auth done'
      if err
        console.error err
      else
        # If the user is logged in, redirect to one of your channels. Your first one?
        # Redirect to the dashboard after a couple of seconds
        # $location.path '/dashboard'
        gotoDashboard()

    # $scope.$auth.$on 'logout', (ev) ->
    #     swal 'logout'

    # Is anyone logged in?
    $scope.$auth.$getCurrentUser().then (user) ->
        # console.info "got user", user
        if user
            gotoDashboard()
        else
            # Show the login options
            $scope.showLogin = true

    gotoDashboard = ->
        # Has this screen been loaded for long enough?
        if Date.now() - startTime > minTime
            # Redirect to the dashboard
            $location.path '/dashboard'
        else
            $timeout ->
                $location.path '/dashboard'
            , minTime - (Date.now() - startTime)



    # Get the list of things from firebase
    useWithRef = $rootScope.rootRef.child "static/useWithSuggestions"
    sync = $firebase useWithRef
    $scope.useWith = sync.$asArray()

    # Once loaded, start rotating
    $scope.idx = 0
    $scope.useWith.$loaded().then ->
        console.log 'loaded useWith'
        console.log $scope.useWith

        $scope.flipper = $interval ->
            if $scope.idx is $scope.useWith.length - 1
                $scope.idx = 0
            else
                $scope.idx++
        , 5000

          

    #       # console.error 'should change path here to go to their home screen'
    #       # console.log 'changing path!'
    #       $scope.$apply ->
    #         $location.path '/dashboard'

    #     # Otherwise, do nothing (until they click the login button)

    # Handle logins
    $scope.login = ->
      $scope.$auth.$login 'facebook'

    # Destroy the interval with the scope
    $scope.$on '$destroy', ->
        if $scope.flipper
            console.log 'destroyed flipper'
            $interval.cancel $scope.flipper




