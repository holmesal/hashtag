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

        scope.loaded = false

        if scope.channel
          console.info "channel changed to #{scope.channel}"

          

          # unregister = scope.$watch 'Channels.messages[scope.channel]', ->
          #   console.info 'scope.messages changed'
          #   console.info scope.messages
          # , true
          setup()

          # scope.messages = sync.$asArray()
          
            # This doesn't do too much here, because the scroll height has to change for these thigns to be loaded properly
            # $timeout ->
            #   scope.loaded = true
            # , 100

      # Do the channel setup
      setup = ->
        console.info 'attempting setup'

        scope.messages = Channels.messages[scope.channel]

        if scope.messages
          console.info 'succeeded'
          scope.messages.$loaded().then ->
            scrollToBottom()
            $timeout ->
              scope.loaded = true
            , 500
        else
          # This is dirty.
          console.info 'waiting...'
          $timeout setup, 200

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
        ,
          queue: false
          duration: 300
      
      # Catch any events coming up from the loadchirp directive
      scope.$on 'heightUpdate', scrollToBottom
  )
