'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:createChannel
 # @description
 # # createChannel
###
angular.module('shortwaveApp')
  .directive('createChannel', (ChannelUtils) ->
    templateUrl: 'views/partials/createChannel.html'
    restrict: 'E'
    scope: {}
    link: (scope, element, attrs) ->

      scope.name = 'hello'

      scope.channelChecker = null

      scope.checkChannel = ->
        if scope.name
          scope.channelChecker = ChannelUtils.checkChannel scope.name
          .then (result) ->
            console.log "DOES CHANNEL #{result.channelName} EXIST? #{result.exists}"
            # These might not come back in the right order
            if result.channelName is scope.name
              scope.channelExists = result.exists
          .catch (err) ->
            console.error "error checking existance of channel #{scope.name}"
            console.error err
          

      scope.createOrJoinChannel = ->
        console.log scope.channelChecker
        scope.channelChecker.finally ->
          console.log 'promise is complete!'

          unless scope.channelExists
            ChannelUtils.createChannel scope.name
            .then ->
              console.log 'created ok!'
              # Channel created ok, clear the textfield and any errors
              scope.takenError = false
              scope.name = ''
              scope.channelExists = null
            .catch (err) ->
              # Creation failed, log it
              console.error "channel #{scope.name} could not be created!"
              console.error err
              # And show an error
              scope.takenError = true
              scope.lastTry = scope.name

          else
            ChannelUtils.joinChannel scope.name
            .then ->
              console.log 'joined ok!'
              # Channel created ok, clear the textfield and any errors
              # scope.takenError = false
              scope.name = ''
              # scope.channelExists = null
            .catch (err) ->
              # Creation failed, log it
              console.error "channel #{scope.name} could not be joined!"
              console.error err
              # And show an error
              # scope.takenError = true
              # scope.lastTry = scope.name
            



        # if scope.name
        #   console.log "creating channel: #{scope.name}"

          
  )
