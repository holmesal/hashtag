'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:DashboardCtrl
 # @description
 # # DashboardCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'DashboardCtrl', ($scope, $rootScope, $filter, $firebase, user) ->

    # Master channels object
    $scope.messages = {}

    # Unread counts
    $scope.unreads = {}

    # Get the current list of channels
    # channelListRef = user.$getRef().child('channels').child 'channels'






    # Track which conversation is currently selected
    $scope.currentChannel = ""
    $scope.channelList = []

    console.log user

    # Bind to the channel list and watch it for changes
    $scope.channelList = user.$child 'channels'

    # When channels are added, start listening to them in messages
    $scope.channelList.$on 'child_added', (ev) ->
      channelName = ev.snapshot.name
      console.log "adding channel #{channelName}"
      # Make a new messages ref
      messagesRef = $rootScope.rootRef.child "/messages/#{channelName}"
      # Make a new angular reference to that location
      $scope.messages[channelName] = $firebase messagesRef
      # Select this channel
      $scope.currentChannel = channelName

    # When channels are removed, remove the listener
    $scope.channelList.$on 'child_removed', (ev) ->
      channelName = ev.snapshot.name
      console.log "deleting channel #{channelName}"
      delete $scope.messages[channelName]

    $scope.$watch 'channelList', (updated, outdated) ->

      # Get an ordered array
      channelList = $filter('orderByPriority')(updated)

      # Loop through each item in the channel list
      # for channelListItem in channelList
        # Compute the unread counts
        # TODO

        # Set up the channel if it doesn't exist yet
        # console.log channelListItem
        # unless $scope.messages[channelListItem.$id]
        #   console.log "adding channel #{channelListItem.$id}"
        #   # Make a new messages ref
        #   messagesRef = $rootScope.rootRef.child "/messages/#{channelListItem.$id}"
        #   # Make a new angular reference to that location
        #   $scope.messages[channelListItem.$id] = $firebase messagesRef

      # Delete any removed channels
      # for outdatedChannel in $filter('orderByPriority')(outdated)
      #   unless $scope.messages[outdatedChannel.$id]
      #     console.log "deleting channel #{outdatedChannel.$id}"
      #     delete $scope.messages[outdatedChannel.$id]

      # TODO - recompute the number of unread messages here
      # console.log $scope.messages

      # If no channel has been set, select the first one
      # if channelList.length > 0
      #   unless $scope.currentChannel
      #     console.log 'setting current channel!'
      #     $scope.currentChannel = channelList[0].$id
    , true

    $scope.setChannel = (channelName) ->
      console.log "changed channel to #{channelName}"
      $scope.currentChannel = channelName