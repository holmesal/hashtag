'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:channelListItem
 # @description
 # # One of the list items that appears in the 
###
angular.module('shortwaveApp')
  .directive('channelListItem', ($rootScope, User) ->
    templateUrl: 'views/partials/channellistitem.html'
    restrict: 'E'
    scope:
      channel: '='
      currentChannel: '='
    link: (scope, element, attrs) ->

      # Handle channel changes
      scope.changeChannel = ->
        # Broadcast the new channel
        $rootScope.$broadcast 'updateChannel', scope.channel.$id
        # scope.currentChannel = scope.channel.$id
        # Set your lastSeen for this channel
        nowRef = $rootScope.rootRef.child "users/#{User.getAuthUser().uid}/channels/#{scope.channel.$id}/lastSeen"
        nowRef.set Date.now()
  )
