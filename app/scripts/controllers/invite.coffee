'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:InviteCtrl
 # @description
 # # InviteCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'InviteCtrl', ($scope, $rootScope, $routeParams, $location, $firebase, ChannelUtils, User) ->
    
    # On init, route params will be available for the channel
    $scope.channelName = $routeParams.channel

    # Ref is the uid of the user, minus the facebook: prefix
    $scope.ref = $routeParams.ref

    $scope.user = User.user

    # Are we logged in?

    # Loaded starts off false
    $scope.loaded = false

    # Get the inviting user 
    ref = $rootScope.rootRef.child "users/facebook:#{$scope.ref}/profile"
    sync = $firebase ref 
    $scope.profile = sync.$asObject()

    # Show the card when the user is loaded
    $scope.profile.$loaded().then ->
      console.log 'loaded profile!'
      $scope.loaded = true


    # Join
    $scope.join = ->
      ChannelUtils.joinChannel $scope.channelName
      .then ->
        console.log 'joined channel successfully!'
        # Set this channel
        ChannelUtils.setViewing $scope.channelName
        # Go to your dashboard
        $location.path '/dashboard'
      , (err) ->
        console.error 'error joining channel'
        console.error err

    $scope.loginAndJoin = ->
      User.login().then ->
        console.info 'logged in!'
        ChannelUtils.joinChannel $scope.channelName
        .then (chan) ->
          console.info "successfully joined channel #{chan}"
          $location.path '/dashboard'
        .catch (err) ->
          console.error "error joining channel", err



