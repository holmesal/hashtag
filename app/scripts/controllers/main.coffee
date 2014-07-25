'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller for the landing page - handle loggin in the user, etc.
###
angular.module('shortwaveApp')
  .controller 'MainCtrl', ($scope, $rootScope, $location, $firebase, $firebaseSimpleLogin) ->

    # TODO - move login checking out to a service that does it in the route resolve - right now said service exists, but this callback is in too many places...
    $scope.$auth = $firebaseSimpleLogin $rootScope.rootRef
    # , (err, authUser) ->
    #   # console.log 'auth done'
    #   if err
    #     console.error err
    #   else
    #     # If the user is logged in, redirect to one of your channels. Your first one?
    #     if authUser
          

    #       # console.error 'should change path here to go to their home screen'
    #       # console.log 'changing path!'
    #       $scope.$apply ->
    #         $location.path '/dashboard'

    #     # Otherwise, do nothing (until they click the login button)

    # Handle logins
    $scope.login = ->
      $scope.auth.login 'facebook'




