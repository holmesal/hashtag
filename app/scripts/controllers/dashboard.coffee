'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:DashboardCtrl
 # @description
 # # DashboardCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'DashboardCtrl', ($scope, $rootScope, $filter, $firebase, user,  Channels) ->

    $rootScope.$on 'updateChannel', (ev, newChannel) ->
      $scope.currentChannel = newChannel

    $scope.showCreate = ->
      $scope.createVisible = true

    $scope.hideCreate = ->
      $scope.createVisible = false