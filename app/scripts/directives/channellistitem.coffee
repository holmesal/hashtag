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

      # Latency - to handle discrepencies in timestamp values
      scope.latency = 1000

      # Get the description
      ref = $rootScope.rootRef.child "channels/#{scope.channel.$id}/meta/description"
      sync = $firebase ref
      scope.description = sync.$asObject()

      # Bind unread
      # unreadChannels = Channels.unread
      # scope.unread = unreadChannels[scope.channel.$id]
      # scope.$watch 'channel.unread', ->
      #   console.log scope.channel.unread


      # Handle channel changes
      scope.changeChannel = ->
        console.log 'changing in response to click'
        # Broadcast the new channel
        $rootScope.$broadcast 'updateChannel', scope.channel.$id
        # scope.currentChannel = scope.channel.$id
        # Set your lastSeen for this channel
        $rootScope.$broadcast 'bumpTime', scope.channel.$id
        

      scope.toggleMute = (ev) ->
        # If undefined or false
        unless scope.channel.muted
          scope.channel.muted = false
        # Flip
        scope.channel.muted = !scope.channel.muted
        # console.log "mute is now #{scope.channel.muted}"
        # Stop the click from propogating further
        ev.stopPropagation()
        # Save the setting
        ChannelUtils.setMute scope.channel.$id, scope.channel.muted
        .then ->
          console.log "channel muted successfully"
        .catch (err) ->
          console.error err

      scope.leave = (ev) ->
        # Leave the channel
        ChannelUtils.leaveChannel scope.channel.$id
        .then ->
          console.log "left channel successfully"
          # Join the first that isn't this one
          list = (channel.$id for channel in Channels.channelList when channel.$id isnt scope.channel.$id)
          console.log "leaving #{scope.channel.$id}"
          console.log "joining #{list[0]}"
          $rootScope.$broadcast 'updateChannel', list[0]
        .catch (err) ->
          console.error err

        # Stop the click from propogating - would trigger a channel change
        ev.stopPropagation()
  )
