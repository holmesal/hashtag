'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, $timeout, $firebaseSimpleLogin, $window, $location, User, Channels, NodeWebkit) ->
    templateUrl: 'views/partials/channellist.html'
    restrict: 'E'
    scope:
      currentChannel: '='
      # showCreate: '='
    link: (scope, element, attrs) ->

      scope.$auth = $firebaseSimpleLogin $rootScope.rootRef

      # Start in the collapsed state
      scope.createVisible = false

      # Hide create anytime the channel changes
      $rootScope.$on 'updateChannel', (ev, newChannel) =>
        scope.createVisible = false

      # Go load the channels from firebase
      scope.uid = User.user.$id
      userRef = $rootScope.rootRef.child "users/#{scope.uid}"
      channelsRef = userRef.child 'channels'
      sync = $firebase channelsRef

      scope.channels = Channels.channelList

      # Once the channels load
      scope.channels.$loaded().then ->

        # Is this user currently viewing any channels?
        user = User.user
        if user.viewing
          channel = user.viewing
        else if scope.channels.length > 0
          # Just pick the first channel
          channel = scope.channels[0].$id
        else
          channel = null

        # Broadcast
        # $rootScope.$broadcast 'updateChannel', channel
        if channel
          scope.currentChannel = channel

      scope.showCreate = ->
        scope.actionState = 'create'

        # else
        #   # Hide create
        #   scope.createVisible = false
        #   # Focus on the input
        #   $rootScope.$broadcast 'focusOn', 'compose'

      scope.cancel = ->
        scope.actionState = null

      scope.logout = ->
        # auth = new FirebaseSimpleLogin $rootScope.rootRef, (err) ->
        #   console.log 'logged out'
        # auth.logout()
        $rootScope.auth.logout()
        NodeWebkit.clearCache()
        $timeout ->
          $window.location.reload()
        , 2000
  )
