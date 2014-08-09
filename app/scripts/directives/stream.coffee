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
      channel: '='
    link: (scope, element, attrs) ->

      scope.loaded = false
      
      scope.$watch 'channel', (up) ->
        if scope.channel

          # Get the new ref
          # messagesRef = $rootScope.rootRef.child "messages/#{scope.channel}"
          # sync = $firebase messagesRef.limit(50)

          # scope.messages = sync.$asArray()
          scope.messages = Channels.messages[scope.channel]

          scope.messages.$loaded().then ->
            scrollToBottom()
            # This doesn't do too much here, because the scroll height has to change for these thigns to be loaded properly
            scope.loaded = true

      # Scroll to bottom anytime messages change
      scope.$watch 'messages', ->
        scrollToBottom()
      , true

      scrollToBottom = =>
        # console.log 'scrolling to the bottom'
        # Scroll the messaages to the bottom
        # For some reason we can't access the child in this way:
        scroller = element.children()[0]

        # So the ghetto way looks like this:
        $('.messages').stop().animate
          scrollTop: scroller.scrollHeight
        , 'slow'
      
      # Catch any events coming up from the loadchirp directive
      scope.$on 'heightUpdate', scrollToBottom
  )
