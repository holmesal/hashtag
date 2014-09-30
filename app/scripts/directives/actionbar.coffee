'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:navbar
 # @description
 # # navbar
###
angular.module('shortwaveApp')
  .directive('actionbar', ($timeout, $rootScope, $firebase, ChannelUtils, Channels, User) ->
    templateUrl: 'views/partials/actionbar.html'
    restrict: 'E'
    scope:
      channelName: '='
    link: (scope, element, attrs) ->
      # element.text 'this is the navbar directive'
      #
      
      scope.$watch 'channelName', (name) ->
        if name
          # Destroy any existing refs
          if scope.channel 
            scope.channel.$destroy()

          # Create a new ref
          sync = new $firebase $rootScope.rootRef.child("users/#{User.user.$id}/channels/#{name}")
          scope.channel = sync.$asObject()
          console.log scope.channel


      # Toggle the muted state of a channel
      scope.toggleMute = ->
        scope.channel.muted = !scope.channel.muted
        scope.channel.$save()

      # Leave the channel
      scope.leave = ->
        conf = window.confirm 'Are you sure you want to leave this channel?'
        if conf
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

      # ref = User.user.$id.replace 'facebook:', ''


      # scope.didCopy = ->
      #   scope.copied = true

      #   $timeout ->
      #     scope.copied = false
      #   , 2000
  )
