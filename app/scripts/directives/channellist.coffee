'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, $timeout, $firebaseSimpleLogin, $window, User, Channels) ->
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

      scope.showCreate = ->
        unless scope.createVisible
          # Show create
          scope.createVisible = true
          # Focus on the element
          $timeout ->
            $rootScope.$broadcast 'focusOn', 'newchannelname'

        else
          # Hide create
          scope.createVisible = false
          # Focus on the input
          $rootScope.$broadcast 'focusOn', 'compose'

      scope.logout = ->
        # auth = new FirebaseSimpleLogin $rootScope.rootRef, (err) ->
        #   console.log 'logged out'
        # auth.logout()
        $rootScope.auth.logout()
        $timeout ->
          $window.location.reload()
        , 200
  )
