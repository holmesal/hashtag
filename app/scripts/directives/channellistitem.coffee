'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelListItem
 # @description
 # # One of the list items that appears in the 
###
angular.module('shortwaveApp')
  .directive('channelListItem', ($rootScope) ->
    templateUrl: 'views/partials/channellistitem.html'
    restrict: 'E'
    scope:
      channel: '='
      currentChannel: '='
    link: (scope, element, attrs) ->

      console.log "comparison #{scope.currentChannel} == #{scope.channel.$id}"

      # Handle channel changes
      scope.changeChannel = ->
        # Broadcast the new channel
        $rootScope.$broadcast 'updateChannel', scope.channel.$id
        # scope.currentChannel = scope.channel.$id
  )
