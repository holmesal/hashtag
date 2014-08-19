'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:InviteCtrl
 # @description
 # # InviteCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'InviteCtrl', ($scope, $routeParams, User) ->
    
    # On init, route params will be available for the channel
    $scope.channel = $routeParams.channel

    # Ref is the uid of the user, minus the facebook: prefix
    $scope.ref = $routeParams.ref

    # User will be full if logged in
    $scope.user = User.getUser()