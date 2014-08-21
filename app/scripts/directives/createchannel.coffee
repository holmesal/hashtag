'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:createChannel
 # @description
 # # createChannel
###
angular.module('shortwaveApp')
  .directive('createChannel', ($filter, $rootScope, $timeout, $firebase, ChannelUtils) ->
    templateUrl: 'views/partials/createChannel.html'
    restrict: 'E'
    scope: {}
    link: (scope, element, attrs) ->

      # On init, focus
      $timeout ->
        $rootScope.$broadcast 'focusOn', 'newchannelname'

      scope.checkChannel = ->
        if scope.name
          scope.channelChecker = ChannelUtils.checkChannel scope.name
          .then (result) ->
            console.log "DOES CHANNEL #{result.channelName} EXIST? #{result.exists}"
            # These might not come back in the right order
            if result.channelName is scope.name
              scope.exists = result.exists
              scope.meta = result.meta
          , (err) ->
            console.error "error checking existance of channel #{scope.name}"
            console.error err

        else
          # Reset
          scope.existing = null
          

      scope.addChannel = ->

        unless scope.exists
          console.log 'creating channel'
          ChannelUtils.createChannel scope.name, scope.description
          .then ->
            console.log 'created ok!'
            # Show that channel
            $rootScope.$broadcast 'updateChannel', scope.name
            # Channel created ok, clear the textfield and any errors
            reset()
          .catch (err) ->
            # Creation failed, log it
            console.error "channel #{scope.name} could not be created!"
            console.error err

        else
          console.log 'joining channel'
          ChannelUtils.joinChannel scope.name
          .then ->
            console.log 'joined ok!'
            # Show said channel
            $rootScope.$broadcast 'updateChannel', scope.name
            # Channel created ok, clear the textfield and any errors
            reset()
          .catch (err) ->
            # Creation failed, log it
            console.error "channel #{scope.name} could not be joined!"
            console.error err

      reset = ->
        scope.name = ''
        scope.description = ''
        scope.meta = null

      scope.keydown = (ev) ->
        scope.addChannel() if ev.keyCode is 13

          
  )
