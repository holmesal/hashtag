'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:composemessage
 # @description
 # # composemessage
###
angular.module('shortwaveApp')
  .directive('composemessage', ($firebaseSimpleLogin, $rootScope) ->
    templateUrl: 'views/partials/composemessage.html'
    restrict: 'E'
    scope: 
      channel: '='
    link: (scope, element, attrs) ->
      # element.text 'this is the composemessage directive'
      scope.$watch 'channel.$id', (newChannel) ->
        if newChannel
          console.log "directive saw channel change to #{newChannel}"

      auth = $firebaseSimpleLogin $rootScope.rootRef

      auth.$getCurrentUser().then (user) ->
        scope.user = user


      # Send a message
      scope.send = ->

        # Build a new message
        message = 
          type: 'text'
          content:
            text: scope.messageText
          owner: scope.user.uid
        
        message['.priority'] = Date.now()

        console.log JSON.stringify(message)

        # Send the message
        # pushRef = scope.channel.$getRef().push()

        # pushRef.setWithPriority message, Date.now(), (err) ->
        #   if err
        #     console.error err
        scope.channel.$add message
        .then ->
          console.log 'saved!'
          # Clear the current text
          scope.messageText = ''
        .catch (err) ->
          console.error err

  )
