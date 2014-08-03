'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:DashboardCtrl
 # @description
 # # DashboardCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'DashboardCtrl', ($scope, $rootScope, $filter, $firebase, user, ChannelUtils) ->

    # Master channels object
    $scope.messages = {}

    # Unread counts
    $scope.unreads = {}

    $scope.currentChannel = undefined

    $rootScope.$on 'updateChannel', (ev, newChannel) ->
        console.log "got update braodcast, new channel is #{newChannel}"
        $scope.currentChannel = newChannel

    # Get the current list of channels
    # channelListRef = user.$getRef().child('channels').child 'channels'

    # watch the channel list
    # channelListRef = user.$ref().child 'channels'
    # $scope.$channelList = $firebase(channelListRef).$asArray()






    # # Track which conversation is currently selected
    # $scope.currentChannel = ""
    # $scope.channelList = {}

    # console.log user

    # # Bind to the channel list and watch it for changes
    # $scope.channelList = user.$child 'channels'

    # # When channels are added, start listening to them in messages
    # $scope.channelList.$on 'child_added', (ev) ->
    #   channelName = ev.snapshot.name
    #   console.log "adding channel #{channelName}"
    #   # Make a new messages ref
    #   messagesRef = $rootScope.rootRef.child "/messages/#{channelName}"
    #   # Make a new angular reference to that location
    #   $scope.messages[channelName] = $firebase messagesRef
    #   # Select this channel
    #   $scope.currentChannel = channelName

    # # When channels are removed, remove the listener
    # $scope.channelList.$on 'child_removed', (ev) ->
    #   channelName = ev.snapshot.name
    #   console.log "deleting channel #{channelName}"
    #   delete $scope.messages[channelName]
    #   # If this thing was the current channel, set it to something else
    #   if channelName is $scope.currentChannel
    #     channelList = $filter('orderByPriority')($scope.channelList)
    #     $scope.currentChannel = channelList[channelList.length-1].$id

    # $scope.$watch 'channelList', (updated, outdated) ->

    #   # Get an ordered array
    #   channelList = $filter('orderByPriority')(updated)
    # , true

    # $scope.setChannel = (channelName) ->
    #   console.log "changed channel to #{channelName}"
    #   $scope.currentChannel = channelName

    # $scope.toggleMute = ->
    #   setTo = !$scope.channelList[$scope.currentChannel].muted
    #   # priorState = !setTo
    #   ChannelUtils.setMute $scope.currentChannel, setTo
    #   .then ->
    #     console.log "set mute properly"
    #   .catch (err) ->
    #     console.error "could not set mute"
    #     console.error err
    #   console.log "Setting mute on channel #{$scope.currentChannel} to #{setTo}"
    # $scope.leaveChannel = ->
    #   ChannelUtils.leaveChannel $scope.currentChannel
    #   .then ->
    #     console.log "left channel #{$scope.currentChannel} properly"
    #   .catch (err) ->
    #     console.log "error leaving channel #{$scope.currentChannel}"
    #     console.log err