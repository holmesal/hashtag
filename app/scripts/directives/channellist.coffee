'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, User) ->
    templateUrl: 'views/partials/channellist.html'
    restrict: 'E'
    scope:
      currentChannel: '='
    link: (scope, element, attrs) ->

      # Go load the channels from firebase
      uid = User.getAuthUser().uid
      userRef = $rootScope.rootRef.child "users/#{uid}"
      channelsRef = userRef.child 'channels'
      sync = $firebase channelsRef

      scope.channels = sync.$asArray()

      scope.channels.$loaded().then ->
        console.log 'channel list loaded'
        console.log scope.channels

        # Is this user currently viewing any channels?
        user = User.getUser()
        if user.viewing
          channel = user.viewing
        else
          # Just pick the first channel
          channel = scope.channels[0].$id
        console.log "the current channel is #{scope.currentChannel}"

        # Broadcast
        # $rootScope.$broadcast 'updateChannel', channel
        scope.currentChannel = channel


  )
