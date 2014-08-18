'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:createChannel
 # @description
 # # createChannel
###
angular.module('shortwaveApp')
  .directive('createChannel', ($filter, $rootScope, $firebase, User, ChannelUtils) ->
    templateUrl: 'views/partials/createChannel.html'
    restrict: 'E'
    scope: {}
    link: (scope, element, attrs) ->

      console.log User.getUser()

      scope.checkChannel = ->
        if scope.name
          scope.channelChecker = ChannelUtils.checkChannel scope.name
          .then (result) ->
            console.log "DOES CHANNEL #{result.channelName} EXIST? #{result.exists}"
            # These might not come back in the right order
            if result.channelName is scope.name
              scope.exists = result.exists
              scope.meta = result.meta
          .catch (err) ->
            console.error "error checking existance of channel #{scope.name}"
            console.error err

          # Make a new ref
          # ref = $rootScope.rootRef.child "channels/#{scope.name}/meta"
          # ref.once 'value', (snap) ->
          #   # Account for checks coming back out of order
          #   if snap.ref().parent().name() is scope.name
          #     scope.existing = snap.val()
            # console.log "#{snap.ref().parent().name()} == #{scope.name}"

          # sync = new $firebase ref
          # scope.existing = sync.$asObject()
        else
          # Reset
          scope.existing = null
          

      scope.addChannel = ->
        console.log scope.channelChecker
        scope.channelChecker.finally ->
          console.log 'promise is complete!'

          unless scope.exists
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
            .fail (err) ->
              console.error err

          else
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
            .fail (err) ->
              console.error err

      reset = ->
        scope.name = ''
        scope.description = ''
        scope.meta = null

      scope.keydown = (ev) ->
        scope.addChannel() if ev.keyCode is 13

          
  )
