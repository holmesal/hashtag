'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:createChannel
 # @description
 # # createChannel
###
angular.module('shortwaveApp')
  .directive('createchannel', (ChannelUtils) ->
    templateUrl: 'views/partials/createchannel.html'
    restrict: 'E'
    link: (scope, element, attrs) ->

      scope.channelChecker = null

      scope.checkChannel = ->
        if scope.channelText
          scope.channelChecker = ChannelUtils.checkChannel scope.channelText
          .then (result) ->
            console.log "DOES CHANNEL #{result.channelName} EXIST? #{result.exists}"
            # These might not come back in the right order
            if result.channelName is scope.channelText
              scope.channelExists = result.exists
          .catch (err) ->
            console.error "error checking existance of channel #{scope.channelText}"
            console.error err
          

      scope.createOrJoinChannel = ->
        console.log scope.channelChecker
        scope.channelChecker.finally ->
          console.log 'promise is complete!'

          unless scope.channelExists
            ChannelUtils.createChannel scope.channelText
            .then ->
              console.log 'created ok!'
              # Channel created ok, clear the textfield and any errors
              scope.takenError = false
              scope.channelText = ''
              scope.channelExists = null
            .catch (err) ->
              # Creation failed, log it
              console.error "channel #{scope.channelText} could not be created!"
              console.error err
              # And show an error
              scope.takenError = true
              scope.lastTry = scope.channelText

          else
            ChannelUtils.joinChannel scope.channelText
            .then ->
              console.log 'joined ok!'
              # Channel created ok, clear the textfield and any errors
              # scope.takenError = false
              # scope.channelText = ''
              # scope.channelExists = null
            .catch (err) ->
              # Creation failed, log it
              console.error "channel #{scope.channelText} could not be joined!"
              console.error err
              # And show an error
              # scope.takenError = true
              # scope.lastTry = scope.channelText
            



        # if scope.channelText
        #   console.log "creating channel: #{scope.channelText}"

          
  )
