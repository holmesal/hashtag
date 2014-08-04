'use strict'

###*
 # @ngdoc directive
 # @name shortwaveApp.directive:message
 # @description
 # # message
###
angular.module('shortwaveApp')
  .directive('message', ($rootScope, $firebase, $sce, $window) ->
    templateUrl: 'views/partials/message.html'
    restrict: 'E'
    scope:
      message: '='
      rolling: '='
    link: (scope, element, attrs) ->

      # scope.vidurl = 'http://zippy.gfycat.com/AlarmingSarcasticGoldenmantledgroundsquirrel.mp4'#message.content.src.mp4

      ownerRef = $rootScope.rootRef.child "users/#{scope.message.owner}/profile"
      sync = $firebase ownerRef
      scope.owner = sync.$asObject()

      # Hacky till this gets moved out into it's own template
      scope.$watch 'message.content.src', (updated) ->
        if updated
          scope.vidurls = 
            mp4: $sce.trustAsResourceUrl(updated.mp4)
            webm: $sce.trustAsResourceUrl(updated.webm)

      # Watch the window scroll
      # windowEl = element.parent()

      # windowEl.on 'scroll', ->
      #   console.log "window scrolled to #{windowEl.scrollTop()}"
      #   scope.offsetTop = windowEl.scrollTop()
      # scope.offsetTop = 100
  )
