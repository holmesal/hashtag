'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:stream
 # @description
 # # stream
###
angular.module('shortwaveApp')
  .directive('stream', ($rootScope, $firebase, $timeout) ->
    templateUrl: 'views/partials/stream.html'
    restrict: 'E'
    scope:
      channel: '='
    link: (scope, element, attrs) ->
      
      scope.$watch 'channel', (up) ->
        console.log 'channel changed to ' + up
        if scope.channel

          # Get the new ref
          messagesRef = $rootScope.rootRef.child "messages/#{scope.channel}"
          sync = $firebase messagesRef.limit(50)

          scope.messages = sync.$asArray()

          scope.messages.$loaded().then ->
            console.log "messages were loaded woohoo!"
            scrollToBottom()

      # Scroll to bottom anytime messages change
      scope.$watch 'messages', ->
        scrollToBottom()

        # $timeout scrollToBottom, 1000
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
        
      scope.$on 'heightUpdate', scrollToBottom
  )
