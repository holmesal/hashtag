'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composebar', ($firebaseSimpleLogin, $rootScope, Message) ->
    templateUrl: 'views/partials/composebar.html'
    restrict: 'E'
    scope: 
      channel: '='
    link: (scope, element, attrs) ->
      # element.text 'this is the composemessage directive'
      scope.$watch 'channel', (newChannel) ->
        if newChannel
          console.log "directive saw channel change to #{newChannel}"

      # auth = $firebaseSimpleLogin $rootScope.rootRef

      # auth.$getCurrentUser().then (user) ->
      #   scope.user = user


      # Send a message
      scope.send = ->
        Message.send scope.channel, scope.messageText
        .then ->
          console.log "send message successfully"
        .catch (err) ->
          console.error "error sending message"
          console.error err
          # restore the old text
          scope.messageText = scope.lastText

        # store the last text
        scope.lastText = scope.messageText
        # Clear the current text
        scope.messageText = ''
        # # Build a new message
        # message = 
        #   type: 'text'
        #   content:
        #     text: scope.messageText
        #   owner: scope.user.uid
        
        # message['.priority'] = Date.now()

        # console.log JSON.stringify(message)

        

        # scope.channel.$add message
        # .then ->
        #   console.log 'saved!'
        # .catch (err) ->
        #   console.error err

      scope.keydown = (ev) ->

        if ev.keyCode is 13
          scope.send()

  )
