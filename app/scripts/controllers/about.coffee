'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
