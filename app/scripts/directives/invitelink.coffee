'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:inviteLink
 # @description
 # # inviteLink
###
angular.module('shortwaveApp')
  .directive('inviteLink', ($timeout, User, Url) ->
    templateUrl: 'views/partials/inviteLink.html'
    restrict: 'E'
    scope: 
      channel: '='
      cancel: '&'
    link: (scope, element, attrs) ->
      scope.link = 'hello there'

      # Grab the current user
      scope.uid = User.user.$id

      # Initialize the clipboard copier


      # Build the ref link for the current channel
      scope.$watch 'channel', ->
        #account for ports
        # portFrag = if $location.$$port then ":#{$location.$$port}" else ''
        #strip facebook string
        ref = scope.uid.replace 'facebook:', ''
        scope.link = "http://sw.mtnlab.io/#{scope.channel}?ref=#{ref}"

      # post-copy
      scope.didCopy = ->
        scope.copied = true
        $timeout ->
          console.log 'will cancel!'
          scope.cancel()
        , 1000
  )
