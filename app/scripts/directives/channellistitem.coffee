'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelListItem
 # @description
 # # One of the list items that appears in the 
###
angular.module('shortwaveApp')
  .directive('channelListItem', ($rootScope, $firebase, $timeout, User, Channels, ChannelUtils) ->
    templateUrl: 'views/partials/channellistitem.html'
    restrict: 'E'
    scope:
      channel: '='
      currentChannel: '='
    link: (scope, element, attrs) ->

      # Get the description
      ref = $rootScope.rootRef.child "channels/#{scope.channel.$id}/meta/description"
      sync = $firebase ref
      scope.description = sync.$asObject()

      # Handle channel changes
      scope.changeChannel = ->
        console.log 'changing in response to click'
        # Broadcast the new channel
        $rootScope.$broadcast 'updateChannel', scope.channel.$id
        # scope.currentChannel = scope.channel.$id
        # Set your lastSeen for this channel
        nowRef = $rootScope.rootRef.child "users/#{User.getAuthUser().uid}/channels/#{scope.channel.$id}/lastSeen"
        nowRef.set Date.now()

      scope.toggleMute = (ev) ->
        scope.channel.muted = !scope.channel.muted
        # console.log "mute is now #{scope.channel.muted}"
        # Stop the event from propogating further
        ev.stopPropagation()
        # Save the setting
        nowRef = $rootScope.rootRef.child "users/#{User.getAuthUser().uid}/channels/#{scope.channel.$id}/muted"
        nowRef.set scope.channel.muted

      scope.leave = (ev) ->
        # Leave the channel
        ChannelUtils.leaveChannel scope.channel.$id
        # Join the first that isn't this one
        list = (channel.$id for channel in Channels.channelList when channel.$id isnt scope.channel.$id)
        console.log "leaving #{scope.channel.$id}"
        console.log list
        console.log list[0]
        $rootScope.$broadcast 'updateChannel', list[0]

        # Stop the event from propogating - would trigger a channel change
        ev.stopPropagation()
  )
