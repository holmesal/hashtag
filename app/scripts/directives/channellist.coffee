'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, User, Channels) ->
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

      scope.channels = Channels.channelList

      # Once the channels load
      scope.channels.$loaded().then ->

        # Is this user currently viewing any channels?
        user = User.getUser()
        if user.viewing
          channel = user.viewing
        else
          # Just pick the first channel
          channel = scope.channels[0].$id

        # Broadcast
        # $rootScope.$broadcast 'updateChannel', channel
        scope.currentChannel = channel

  )
