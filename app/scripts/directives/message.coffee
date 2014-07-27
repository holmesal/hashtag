'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:message
 # @description
 # # message
###
angular.module('shortwaveApp')
  .directive('message', ($rootScope, $firebase, $sce) ->
    templateUrl: 'views/partials/message.html'
    restrict: 'E'
    scope:
      message: '='
      rolling: '='
    link: (scope, element, attrs) ->

      console.log scope.message
      console.log scope.rolling

      # scope.vidurl = 'http://zippy.gfycat.com/AlarmingSarcasticGoldenmantledgroundsquirrel.mp4'#message.content.src.mp4

      ownerRef = $rootScope.rootRef.child "users/#{scope.message.owner}/profile"
      scope.owner = $firebase ownerRef


      # Hacky till this gets moved out into it's own template
      scope.$watch 'message.content.src.mp4', (updated) ->
        if updated
          scope.vidurl = $sce.trustAsResourceUrl(updated)
  )
