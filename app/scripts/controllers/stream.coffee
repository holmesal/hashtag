'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:StreamCtrl
 # @description
 # # StreamCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'StreamCtrl', ($scope, $rootScope, $firebase, channel) ->

    ref = new Firebase "#{$rootScope.firebaseURL}/messages/#{channel.name}"

    sync = $firebase ref

    $scope.messages = sync.$asArray()

    $scope.messages.$loaded().then ->
      console.log 'messages all loaded!'
      console.log $scope.messages
