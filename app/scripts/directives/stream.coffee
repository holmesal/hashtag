'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:stream
 # @description
 # # stream
###
angular.module('shortwaveApp')
  .directive('stream', ($rootScope, $firebase, $timeout, Channels) ->
    templateUrl: 'views/partials/stream.html'
    restrict: 'E'
    scope:
      channelName: '='
    link: (scope, element, attrs) ->

      scope.loaded = false
      
      scope.$watch 'channelName', (up) ->

        scope.loaded = false

        if scope.channelName
          console.info "channel changed to #{scope.channelName}"
          setup()

      # Do the channel setup
      setup = ->

        # Load the messages
        ref = $rootScope.rootRef.child "messages/#{scope.channelName}"
        sync = $firebase ref.limit(100)
        scope.messages = sync.$asArray()

        scope.messages.$loaded().then ->
          $timeout ->
            scrollToBottom()
            scope.loaded = true
          , 500

          # Bump your last seen time every time you see a message
          scope.messages.$watch (ev) ->
            if ev.event is 'child_added'
              # A new message was added, bump the time
              $rootScope.$broadcast 'bumpTime', scope.channelName

      # Scroll to bottom anytime messages change
      scope.$watch 'messages', ->
        scrollToBottom()
      , true

      scrollToBottom = =>
        console.log 'scrolling to the bottom'
        # Scroll the messaages to the bottom
        # For some reason we can't access the child in this way:
        scroller = element.children()[0]

        console.log scroller.scrollHeight

        # So the ghetto way looks like this:
        # $('.messages').stop().animate
        $('html,body').stop().animate
          scrollTop: "#{scroller.scrollHeight}px"
        ,
          queue: false
          duration: 300
      
      # Catch any events coming up from the loadchirp directive
      scope.$on 'heightUpdate', scrollToBottom
  )
