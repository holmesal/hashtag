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

      scope.createChannel = ->

        console.log "creating channel: #{scope.newChannelName}"

        ChannelUtils.createChannel scope.newChannelName
        .then ->
          console.log 'created ok!'
          # Channel created ok, clear the textfield and any errors
          scope.takenError = false
          scope.newChannelName = ''
        .catch (err) ->
          # Creation failed, log it
          console.error "channel #{scope.newChannelName} could not be created!"
          console.error err
          # And show an error
          scope.takenError = true
          scope.lastTry = scope.newChannelName
          
  )
