'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelList
 # @description
 # # channelList
###
angular.module('shortwaveApp')
  .directive('channelList', ($firebase, $rootScope, $timeout, $firebaseSimpleLogin, $window, $location, User, Channels, ChannelUtils, NodeWebkit, Analytics) ->
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

      scope.channels = Channels.channels
      # scope.channels = sync.$asArray()

      # Once the channels load
      scope.channels.$loaded().then (chans) ->

        # console.log scope.channels

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
          # console.log 'got results', data
          # Are there results?
          if data?.results
            scope.suggestions = data.results
            scope.resultRef.off()
          else
            scope.suggestions = []
          scope.$apply ->

      scope.reset = (cancel=false)->
        scope.addName = ''
        scope.addMode = false
        if scope.resultRef
          scope.resultRef.off()
        scope.suggestions = []
        if cancel
          Analytics.track 'Add Channel Cancel'

      scope.addChannel = (channelName, tappedResult) ->
        ChannelUtils.addChannel channelName
          .then (isCreate) ->
            # console.log 'added ok!'
            # Show that channel
            $rootScope.$broadcast 'updateChannel', channelName
            Analytics.track 'Add Channel Success',
              channel: channelName
              isCreate: isCreate
              tappedResult: tappedResult
            # Channel created ok, clear the textfield and any errors
            scope.reset()
          .catch (err) ->
            # Creation failed, log it
            console.error "channel #{scope.name} could not be added!"
            console.error err
            Analytics.track 'Add Channel Error',
              channel: channelName
              error: err


      scope.toggleMode = ->
        scope.addMode = true
        Analytics.track 'Add Channel Open'
        $timeout ->
          $rootScope.$broadcast 'focusOn', 'add'

      scope.logout = ->
        $rootScope.auth.logout()
        NodeWebkit.clearCache()
        Analytics.track 'Logout'
        $timeout ->
          NodeWebkit.restart()
        , 20
  )
