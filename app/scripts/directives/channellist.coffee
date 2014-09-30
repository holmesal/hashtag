'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, $timeout, $firebaseSimpleLogin, $window, $location, User, Channels, ChannelUtils, NodeWebkit) ->
    templateUrl: 'views/partials/channellist.html'
    restrict: 'E'
    scope:
      currentChannel: '='
      # showCreate: '='
    link: (scope, element, attrs) ->

      searchQueueRef = $rootScope.rootRef.child 'searchQueue'

      # current search ref
      scope.resultRef = null

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

      scope.search = ->
        if scope.resultRef
          # Remove all listeners
          scope.resultRef.off()
          scope.suggestions = []

        # Make a new search
        searchRef = searchQueueRef.child('query').push()
        searchRef.set 
          query: scope.addName

        # Make a new result
        scope.resultRef = searchQueueRef.child "result/#{searchRef.name()}"
        scope.resultRef.on 'value', (snap) ->
          data = snap.val()
          console.log 'got results', data
          # Are there results?
          if data?.results
            scope.suggestions = data.results
            scope.resultRef.off()
          else
            scope.suggestions = []
          scope.$apply ->

      scope.reset = ->
        scope.addName = ''
        scope.addMode = false
        if scope.resultRef
          scope.resultRef.off()
        scope.suggestions = []

      scope.addChannel = (channelName) ->
        ChannelUtils.addChannel channelName
          .then ->
            console.log 'added ok!'
            # Show that channel
            $rootScope.$broadcast 'updateChannel', channelName
            # Channel created ok, clear the textfield and any errors
            scope.reset()
          .catch (err) ->
            # Creation failed, log it
            console.error "channel #{scope.name} could not be added!"
            console.error err


      scope.toggleMode = ->
        scope.addMode = true
        $timeout ->
          $rootScope.$broadcast 'focusOn', 'add'

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
