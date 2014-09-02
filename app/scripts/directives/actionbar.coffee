'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:navbar
 # @description
 # # navbar
###
angular.module('shortwaveApp')
  .directive('actionbar', ($timeout, User) ->
    templateUrl: 'views/partials/actionbar.html'
    restrict: 'E'
    scope:
      channelName: '='
    link: (scope, element, attrs) ->
      # element.text 'this is the navbar directive'

      ref = User.user.$id.replace 'facebook:', ''

      scope.$watch 'channelName', ->
        scope.link = "http://wavelength.im/#{scope.channelName}?ref=#{ref}"

      scope.didCopy = ->
        scope.copied = true

        $timeout ->
          scope.copied = false
        , 2000
  )
